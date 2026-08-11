# Custom chat-list screen (host app)

**For:** host-app developers  
**Opt-in:** omit `conversationScreenBuilder` → SDK default Messages UI is unchanged

Use this when the host app wants its own Messages screen (header, search, Shared With You, filter pills, custom rows, etc.). The SDK still owns lifecycle (MQTT, conversations controller), conversation data, and opening a chat.

---

## 1. Set `conversationProperties`

Pass `conversationScreenBuilder` on `IsmChatConversationProperties`:

```dart
IsmChatApp(
  context: context,
  conversationProperties: IsmChatConversationProperties(
    conversationScreenBuilder: (context) {
      return YourMessagesScreen(
        onSignOut: () {
          // host sign-out
        },
      );
    },
  ),
);
```

Omit the builder (or leave it null) to keep the SDK chat-list screen.

SDK still:
- Initializes MQTT + `IsmChatConversationsController` when `IsmChatConversations` mounts
- On **web**, wraps your screen in the left column so `openConversation` can show the chat page on the right

---

## 2. Full host sample (copy / paste)

Includes search, stub Shared With You, filter chips, list, pull-to-refresh, load more, and `openConversation`. Replace Shared With You / Brands / Requests with your real host data.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class YourMessagesScreen extends StatefulWidget {
  const YourMessagesScreen({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  State<YourMessagesScreen> createState() => _YourMessagesScreenState();
}

class _YourMessagesScreenState extends State<YourMessagesScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';

  static const _filters = ['All', 'Unread', 'Brands', 'Requests'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IsmChatConversationModel> _applyFilter(
    List<IsmChatConversationModel> all,
  ) {
    switch (_filter) {
      case 'Unread':
        return all.where((c) => (c.unreadMessagesCount ?? 0) > 0).toList();
      case 'Brands':
      case 'Requests':
        // Host-owned filters — plug in your brand / request logic.
        return all;
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetX<IsmChatConversationsController>(
      tag: IsmChat.i.chatListPageTag,
      builder: (_) {
        if (IsmChat.i.isChatListLoading &&
            IsmChat.i.chatListConversations.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final conversations = _applyFilter(IsmChat.i.chatListConversations);
        final unreadCount = IsmChat.i.chatListConversations
            .where((c) => (c.unreadMessagesCount ?? 0) > 0)
            .length;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B3A6B),
            foregroundColor: Colors.white,
            title: const Text('Messages'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: IsmChat.i.refreshChatList,
              ),
              if (widget.onSignOut != null)
                IconButton(
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout),
                  onPressed: widget.onSignOut,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: IsmChat.i.refreshChatList,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: IsmChat.i.searchChatList,
                      decoration: InputDecoration(
                        hintText: 'Search people, brands, products',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SharedWithYouSection()),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final label = _filters[index];
                        final selected = _filter == label;
                        final chipLabel = label == 'Unread' && unreadCount > 0
                            ? 'Unread $unreadCount'
                            : label;
                        return ChoiceChip(
                          label: Text(chipLabel),
                          selected: selected,
                          onSelected: (_) => setState(() => _filter = label),
                          selectedColor: const Color(0xFF1B3A6B),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (conversations.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No conversations')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == conversations.length) {
                          return TextButton(
                            onPressed: IsmChat.i.loadMoreChatList,
                            child: const Text('Load more'),
                          );
                        }
                        final conversation = conversations[index];
                        final unread = conversation.unreadMessagesCount ?? 0;
                        return ListTile(
                          tileColor: Colors.white,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1B3A6B),
                            foregroundColor: Colors.white,
                            child: Text(
                              (conversation.chatName.isNotEmpty
                                      ? conversation.chatName[0]
                                      : '?')
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(
                            conversation.chatName.isNotEmpty
                                ? conversation.chatName
                                : 'Chat',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            conversation.lastMessageDetails?.body ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if ((conversation.lastMessageSentAt ?? 0) > 0)
                                Text(
                                  conversation.lastMessageSentAt!
                                      .toMessageDateString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (unread > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B3A6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () =>
                              IsmChat.i.openConversation(conversation),
                        );
                      },
                      childCount: conversations.length + 1,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Host-owned section — replace stub items with your Shared With You API data.
class SharedWithYouSection extends StatelessWidget {
  const SharedWithYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Lavender Wash', '\$0.96 back'),
      ('Face Serum', '\$1.20 back'),
      ('Candle Set', '\$0.45 back'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text(
                'SHARED WITH YOU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.brown.shade400,
                ),
              ),
              const Spacer(),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E4DE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      item.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
```

**Host-owned (not provided by SDK):** Shared With You carousel data, Brands / Requests filter logic, product icons in subtitles. Filter `chatListConversations` locally as in the sample, or pass `conversationPredicate` for SDK-side filtering.

---

## 3. Action APIs (`IsmChat.i`)

Call these while the chat-list screen is open (after `IsmChatApp` / `IsmChatConversations` has mounted). If the conversations controller is not registered, methods no-op / return empty.

### Methods

| Method | What it does |
|---|---|
| `refreshChatList()` | Pull-to-refresh (same path as SDK list refresh + unread count). |
| `loadMoreChatList()` | Next page of conversations (pagination). |
| `searchChatList(String query)` | Search; empty / whitespace clears search and reloads. |
| `openConversation(IsmChatConversationModel)` | Opens chat (mobile route push / web split pane). Same path as SDK row tap. |

### Getters

| Getter | Type | What it is |
|---|---|---|
| `chatListConversations` | `List<IsmChatConversationModel>` | Current filtered list (`userConversations`). |
| `isChatListLoading` | `bool` | Initial / loading flag. |
| `chatListPageTag` | `String?` | GetX tag for `IsmChatConversationsController` (already existed). |

---

## 4. Other useful calls

```dart
// Search
await IsmChat.i.searchChatList('Maya');

// Clear search
await IsmChat.i.searchChatList('');

// Pagination (e.g. scroll end)
await IsmChat.i.loadMoreChatList();

// Open chat
await IsmChat.i.openConversation(conversation);
```

For live list updates (MQTT, refresh), rebuild when `IsmChatConversationsController` changes, e.g. `GetX` / `Obx` with `tag: IsmChat.i.chatListPageTag`.

---

## 5. Notes

- Do **not** skip `IsmChatApp` / `IsmChatConversations` lifecycle. Always mount chat via `IsmChatApp` (or equivalent) so controllers initialize; only the **visual** tree is replaced.
- Existing `header` / `cardBuilder` / FAB options still apply to apps that **omit** `conversationScreenBuilder`. They are ignored for layout when the host owns the full screen.
- Web: your builder fills the **left** column; the SDK keeps the right chat pane so `openConversation` works without host web layout code.
