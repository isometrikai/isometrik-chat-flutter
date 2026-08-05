# Custom chat composer (host app)

**For:** host-app developers  
**Opt-in:** omit `messageFieldBuilder` → SDK default bar is unchanged

Use this when the host app wants its own typing / bottom bar (layout, `+`, capsule field, send button, etc.). The SDK still sends messages, attachments, typing, and replies.

---

## 1. Set `chatPageProperties`

Pass `messageFieldBuilder` on `IsmChatPageProperties` (same place as other chat-page options):

```dart
IsmChatApp(
  chatPageProperties: IsmChatPageProperties(
    messageFieldBuilder: (context, conversation) {
      return YourComposer(); // your UI
    },
  ),
);
```

Return `null` from the builder (or don’t set it) to keep the SDK composer.

SDK still hides the bar first when the user left / was removed from a group, the opponent is deleted, or `messageAllowedConfig` blocks input.

---

## 2. Minimum composer

Bind the SDK controller and call `IsmChat.i` for actions:

```dart
class YourComposer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final input = IsmChat.i.chatInputController;
    if (input == null) return const SizedBox.shrink();

    return SafeArea(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => IsmChat.i.openComposerAttachments(context),
          ),
          Expanded(
            child: TextField(
              controller: input,
              focusNode: IsmChat.i.chatInputFocusNode,
              onChanged: IsmChat.i.onComposerTextChanged,
              decoration: const InputDecoration(hintText: 'Message'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => IsmChat.i.sendComposerText(),
          ),
        ],
      ),
    );
  }
}
```

Or send without binding the controller:

```dart
await IsmChat.i.sendComposerText(text: 'Hello');
```

---

## 3. Action APIs (`IsmChat.i`)

Call these only while the chat page is open. If it isn’t, methods no-op / return `false` / `null`.

### Methods

| Method | What it does |
|---|---|
| `sendComposerText({String? text})` | Sends text (same path as SDK send: block check, `isMessgeAllowed`, mentions, reply). Uses `chatInputController` if `text` is omitted. Returns `true` if send started. |
| `openComposerAttachments([BuildContext? context])` | Opens the SDK attachment sheet (camera, gallery, document, location, contact). |
| `selectComposerAttachment(IsmChatAttachmentType type, {BuildContext? context})` | Skips the sheet and runs one type, e.g. `IsmChatAttachmentType.gallery`. |
| `onComposerTextChanged(String text)` | Call from `TextField.onChanged`. Typing indicator + @mentions. Syncs text into the SDK controller if you use your own. |
| `notifyComposerTyping()` | Typing indicator only (no mention handling). |
| `cancelComposerReply()` | Clears reply state / preview. |
| `toggleComposerEmojiBoard([bool? show])` | Shows / hides the SDK emoji board under the composer. |
| `showComposerBlockDialog()` | Shows block / unblock dialog when chatting is not allowed. |

### Getters

| Getter | Type | What it is |
|---|---|---|
| `chatInputController` | `TextEditingController?` | Bind your `TextField` to this. |
| `chatInputFocusNode` | `FocusNode?` | Optional focus node for the field. |
| `currentChatConversation` | `IsmChatConversationModel?` | Open conversation. |
| `isChattingAllowed` | `bool` | Whether the user may send. If `false`, call `showComposerBlockDialog()`. |
| `isChatReplying` | `bool` | Reply is active. |
| `chatReplyMessage` | `IsmChatMessageModel?` | Message being replied to (show preview + close → `cancelComposerReply()`). |

---

## 4. Other useful calls

```dart
// Attach without the sheet
await IsmChat.i.selectComposerAttachment(IsmChatAttachmentType.camera);

// Reply UI
if (IsmChat.i.isChatReplying) {
  // show IsmChat.i.chatReplyMessage?.body
  // close → IsmChat.i.cancelComposerReply();
}

// Blocked / not allowed
if (!IsmChat.i.isChattingAllowed) {
  IsmChat.i.showComposerBlockDialog();
  return;
}

// Emoji board (SDK panel below your bar)
IsmChat.i.toggleComposerEmojiBoard();
```

For live reply updates, rebuild when `IsmChatPageController.isreplying` changes (e.g. `GetX<IsmChatPageController>(tag: IsmChat.i.chatPageTag, ...)`).

---

## 5. Notes

- Do **not** call `IsmChatPageController.sendTextMessage` from the host app. Use `IsmChat.i.sendComposerText`.
- `attachments` / `features` / `messageAllowedConfig` on `chatPageProperties` still apply.
- Working sample: `example/lib/views/chat_list.dart` → `_ExampleHostComposer`.
