# Custom chat input area (host app)

**For:** host-app developers  
**Opt-in:** omit `chatInputAreaBuilder` → SDK default composer is unchanged

Use this when the host wants anything **below the message list**: Common Questions, Share carousel, custom composer, or a combination. The sticky banner under the header uses existing `header.bottom` (see below).

> **Migration:** `messageFieldBuilder` is **deprecated**. Prefer `chatInputAreaBuilder`. Old apps that only set `messageFieldBuilder` still work until you migrate.

---

## 1. Wire `chatPageProperties`

```dart
IsmChatApp(
  context: context,
  chatPageProperties: IsmChatPageProperties(
    header: IsmChatPageHeaderProperties(
      // Must cover toolbar + banner (use IsmChatDimens.appBarHeight, not kToolbarHeight).
      height: (context, conversation) =>
          IsmChatDimens.appBarHeight + StickyChatBanner.height,
      bottom: (context, conversation) => const StickyChatBanner(),
    ),
    chatInputAreaBuilder: (context, conversation, defaultComposer) {
      return ChatInputArea(
        conversation: conversation,
        defaultComposer: defaultComposer,
      );
    },
  ),
);
```

| Want | Return from `chatInputAreaBuilder` |
|---|---|
| Strip + SDK composer | `Column(strip, defaultComposer)` |
| Strip + custom composer | `Column(strip, YourComposer())` |
| Custom composer only | `YourComposer()` |
| Strip only (no input) | just the strip |
| Default only | omit builder |

SDK adds **no** divider/padding. Put separators in your widget if needed.  
When `chatInputAreaBuilder` is set, it **wins** over `messageFieldBuilder`.

Restriction states still hide the whole input area first (left/removed from group, deleted opponent, `messageAllowedConfig`).

---

## 2. Full copy/paste sample

### Sticky banner (`header.bottom`)

```dart
class StickyChatBanner extends StatelessWidget {
  const StickyChatBanner({super.key});

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: const Color(0xFFE8F5E9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You both earn 5% cash back on anything shared here',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Below messages: Common Questions + composer

Same slot works for a Share carousel — swap the strip widget; keep `defaultComposer` or your own field.

```dart
class ChatInputArea extends StatelessWidget {
  const ChatInputArea({
    super.key,
    required this.conversation,
    required this.defaultComposer,
    this.useCustomComposer = false,
  });

  final IsmChatConversationModel? conversation;
  final Widget defaultComposer;

  /// `false` → SDK composer; `true` → [HostComposer].
  final bool useCustomComposer;

  static const _questions = [
    'Is this safe around pets?',
    'How many loads per bottle?',
    'Where is my refill?',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMON QUESTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _questions.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        ActionChip(
                          label: Text(_questions[i]),
                          onPressed: () =>
                              IsmChat.i.sendComposerText(text: _questions[i]),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (useCustomComposer) const HostComposer() else defaultComposer,
      ],
    );
  }
}
```

### Optional custom composer

```dart
class HostComposer extends StatelessWidget {
  const HostComposer({super.key});

  static const _navy = Color(0xFF1B3A6B);

  @override
  Widget build(BuildContext context) {
    return GetX<IsmChatPageController>(
      tag: IsmChat.i.chatPageTag,
      builder: (controller) {
        final input = controller.chatInputController;

        return Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.isreplying) ...[
                    // show reply preview; close → IsmChat.i.cancelComposerReply()
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: _navy,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () =>
                            IsmChat.i.openComposerAttachments(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: input,
                          focusNode: IsmChat.i.chatInputFocusNode,
                          minLines: 1,
                          maxLines: 4,
                          onChanged: IsmChat.i.onComposerTextChanged,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: _navy,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => IsmChat.i.sendComposerText(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

---

## 3. Composer actions (`IsmChat.i`)

Call these while the chat page is open (when using a custom composer instead of `defaultComposer`):

| Method / getter | What it does |
|---|---|
| `sendComposerText({String? text})` | Send text |
| `openComposerAttachments([context])` | Attachment sheet |
| `selectComposerAttachment(type)` | One attachment type |
| `onComposerTextChanged(text)` | Typing + mentions |
| `chatInputController` / `chatInputFocusNode` | Bind your `TextField` |
| `cancelComposerReply()` / `isChatReplying` / `chatReplyMessage` | Reply UI |
| `isChattingAllowed` / `showComposerBlockDialog()` | Blocked state |

---

## 4. Notes

- Sticky banner = `header.bottom` + `header.height` = `IsmChatDimens.appBarHeight + bannerHeight`
- Below messages = `chatInputAreaBuilder` only (one common callback)
- In-thread product cards / quick replies stay host `messageBuilder` — no extra SDK slot
- Do **not** call `IsmChatPageController.sendTextMessage` from the host; use `IsmChat.i.sendComposerText`
