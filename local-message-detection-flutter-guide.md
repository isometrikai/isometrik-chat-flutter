# On-Device Message Safety Check — Flutter Implementation Guide

## Goal
Add a fast, on-device check that runs **before** a message is sent, to catch obvious scam/phishing/inappropriate content instantly (no network delay). This is a **first line of defense** for UX purposes only — the backend safety pipeline remains the real security boundary, since anything running on the user's device can be bypassed by a modified app.

---

## Architecture Overview

```
User types message
      │
      ▼
[1] Local rule filter (regex/keywords) — instant, always runs
      │
      ├─ Clearly bad → block locally, show warning, don't send
      ├─ Clearly fine → send immediately
      └─ Unsure → run local ML model
                     │
                     ├─ High risk → block locally, show warning
                     └─ Low/unclear risk → send anyway
                                              │
                                              ▼
                          Backend pipeline (rules → AI classifier → human review)
                          — this is the real gatekeeper, always runs regardless
                          of what the local check decided
```

---

## Step 1: Add the local rule filter (do this first — highest value, lowest effort)

No ML needed. Catches most obvious cases: phone numbers, external contact handles, links, known scam phrases.

**File:** `lib/safety/local_message_filter.dart`

```dart
class LocalMessageFilter {
  static final _phonePattern = RegExp(r'(\+?\d[\d\-\s]{7,}\d)');
  static final _urlPattern = RegExp(r'(https?:\/\/|www\.)\S+');
  static final _handlePattern = RegExp(
    r'\b(whatsapp|telegram|snap(chat)?|insta(gram)?)\b',
    caseSensitive: false,
  );
  static final _scamPhrases = RegExp(
    r'\b(invest|crypto|forex|loan|send money|gift card)\b',
    caseSensitive: false,
  );

  static bool isSuspicious(String text) {
    return _phonePattern.hasMatch(text) ||
        _urlPattern.hasMatch(text) ||
        _handlePattern.hasMatch(text) ||
        _scamPhrases.hasMatch(text);
  }
}
```

Maintain the keyword/regex lists as a config (ideally fetched from remote config, not hardcoded) so they can be updated without an app release.

**Deliverable:** ship this alone first. It requires no model, no training pipeline, and can go live within a day or two.

---

## Step 2 (optional, phase 2): Add a local ML classifier for nuanced/paraphrased cases

This is for catching things like "reach me on the app that starts with W" — cases regex won't catch. This is more effort and should be a separate phase.

### 2a. Model training (done outside Flutter, in Python — not a dev task, a data/ML task)
- Train a lightweight text classifier (NOT a full LLM) — e.g. an average-word-embedding + dense-layer classifier using **TensorFlow Lite Model Maker**, or a small distilled/quantized model.
- Training data: confirmed scam messages from your backend's flagged/reviewed history + clean messages as negatives.
- Export to `.tflite` format, quantized. Target size: a few MB max, sub-50ms inference on a mid-range phone.
- This step needs someone with ML/data experience — flag this as a separate task from the Flutter integration work.

### 2b. Flutter integration
**Package:** [`tflite_flutter`](https://pub.dev/packages/tflite_flutter)

```yaml
dependencies:
  tflite_flutter: ^0.10.4
```

Bundle the model as an asset:
```yaml
flutter:
  assets:
    - assets/scam_classifier.tflite
```

**File:** `lib/safety/scam_classifier.dart`

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

class ScamClassifier {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/scam_classifier.tflite');
  }

  Future<double> classify(String text) async {
    return compute(_runInference, text); // runs off the UI thread
  }

  double _runInference(String text) {
    final input = _preprocess(text); // tokenize/vectorize to match model's expected input
    final output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter.run(input, output);
    return output[0][0]; // probability of "scam"
  }

  List<List<double>> _preprocess(String text) {
    // TODO: implement tokenizer matching the training pipeline's vocabulary
    throw UnimplementedError();
  }
}
```

**Important:** the `_preprocess` step must exactly match however the model was trained to vectorize text (same tokenizer/vocabulary). This is usually provided by whoever trains the model, alongside the `.tflite` file.

---

## Step 3: Wire into the send flow (Isometrik Chat SDK)

The Flutter Chat SDK already exposes a pre-send gate on
`IsmChatPageProperties.messageAllowedConfig`. Prefer the richer callbacks:

```dart
IsmChatProperties.chatPageProperties = IsmChatPageProperties(
  messageAllowedConfig: MessageAllowedConfig(
    // Preferred: allow / block / keepLocal (+ reason for logging)
    onBeforeSendMessage: (context, conversation, customType, text) async {
      if (text != null && LocalMessageFilter.isSuspicious(text)) {
        // Show in chat locally, never hit send API
        return IsmChatMessageSendDecision.keepLocal(reason: 'phishing_filter');
        // Or discard entirely:
        // return IsmChatMessageSendDecision.block(reason: 'phishing_filter');
      }
      return IsmChatMessageSendDecision.allow();
    },
    // Host analytics / logging when blocked or kept local-only
    onMessageSendBlocked: (message, decision) {
      // e.g. FirebaseAnalytics / Sentry / your backend log
      debugPrint(
        'send blocked: ${decision.action} reason=${decision.reason} '
        'body=${message.body}',
      );
    },
  ),
);
```

- `allow` — normal send (pending → API)
- `block` — do not send; message stays in the input
- `keepLocal` — bubble shown + saved to main DB with `isInvalidMessage`, **no API**
- Legacy `isMessgeAllowed` (`bool`) still works: `false` ≡ `block`

Optional phase-2 ML block (skip if not implemented yet):

```dart
Future<void> onSendPressed(String text) async {
  if (LocalMessageFilter.isSuspicious(text)) {
    final risk = await scamClassifier.classify(text);
    if (risk > 0.8) {
      showWarningDialog(
        "This message looks like it might violate our safety guidelines. "
        "Please avoid sharing contact details or links in chat.",
      );
      return; // don't send
    }
  }
  await sendMessage(text); // still goes through backend pipeline regardless
}
```

---

## Step 4: Testing checklist

- [ ] Regex filter catches: phone numbers, common messaging app names, URLs, known scam phrases
- [ ] Regex filter does NOT false-positive on normal conversation (test with a sample of real clean messages)
- [ ] Local check runs with no noticeable UI delay (should be instant for regex, <100ms for ML classify)
- [ ] ML inference runs off the main isolate (UI doesn't freeze while typing/sending)
- [ ] Backend pipeline still runs and still blocks bad messages even if local check missed them (confirm local check is not a single point of failure)
- [ ] Keyword/regex list can be updated remotely without requiring an app store release
- [ ] Warning message shown to user is clear and non-punitive in tone for borderline cases

---

## Rollout plan

1. **Ship Step 1 (regex filter) first** — fast to build, immediate value, no ML dependency.
2. **Monitor false positive/negative rate** using backend data (compare what local filter would have caught vs. what backend actually caught).
3. **Only build Step 2 (local ML model)** if regex alone leaves a meaningful gap for paraphrased scam attempts.
4. **Backend remains the source of truth** at every phase — this local layer is a UX enhancement and load-reducer, not a replacement for server-side moderation.

---

## Notes for the Flutter dev

- The `_preprocess` function in `ScamClassifier` needs a matching tokenizer from whoever trains the model — don't guess this, request it alongside the `.tflite` file.
- Keep the local model small and versioned; plan to update it periodically as scam patterns evolve (via remote config or in-app model download, not just app releases).
- Local blocking should never be the only check — always confirm messages still pass through the backend pipeline regardless of local result, to prevent a compromised/modified app from bypassing moderation entirely.
