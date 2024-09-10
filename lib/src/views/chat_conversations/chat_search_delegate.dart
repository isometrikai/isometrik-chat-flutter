import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatSearchDelegate extends SearchDelegate<void> {
  IsmChatSearchDelegate({required this.onChatTap});

  final _controller = Get.find<IsmChatConversationsController>();
  final void Function(BuildContext, IsmChatConversationModel, bool) onChatTap;
  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.trim().isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              query = '';
            },
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          close(context, null);
        },
      );

  @override
  Widget buildResults(BuildContext context) => Obx(
        () => _controller.suggestions.isEmpty
            ? Center(
                child: Text(
                  IsmChatStrings.noMatch,
                  style: IsmChatStyles.w600Black20,
                ),
              )
            : ListView.builder(
                itemCount: _controller.suggestions.length,
                itemBuilder: (_, index) =>
                    IsmChatConversationCard(_controller.suggestions[index]),
              ),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    _controller.onSearch(query.trim());
    return Obx(
      () => _controller.suggestions.isEmpty
          ? Center(
              child: SizedBox(
                width: IsmChatDimens.percentWidth(.6),
                child: Text(
                  IsmChatStrings.noMatch,
                  style: IsmChatStyles.w600Black20,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SizedBox(
              child: ListView.builder(
                itemCount: _controller.suggestions.length,
                itemBuilder: (_, index) {
                  var conversation = _controller.suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      _controller.updateLocalConversation(conversation);
                      onChatTap(_, conversation, false);
                    },
                    child: IsmChatConversationCard(
                      _controller.suggestions[index],
                      nameBuilder: (_, __, name) {
                        if (!name.didMatch(query)) {
                          return null;
                        }
                        var before = name.substring(
                            0, name.toLowerCase().indexOf(query.toLowerCase()));
                        var match = name.substring(
                            before.length, before.length + query.length);
                        var after =
                            name.substring(before.length + match.length);
                        return RichText(
                          text: TextSpan(
                            text: before,
                            style: IsmChatStyles.w600Black14,
                            children: [
                              TextSpan(
                                text: match,
                                style: TextStyle(
                                    color:
                                        IsmChatConfig.chatTheme.primaryColor),
                              ),
                              TextSpan(
                                text: after,
                              ),
                            ],
                          ),
                        );
                      },
                      subtitleBuilder: (_, __, msg) {
                        if (!msg.didMatch(query)) {
                          return null;
                        }
                        var before = msg.substring(
                            0, msg.toLowerCase().indexOf(query.toLowerCase()));
                        var match = msg.substring(
                            before.length, before.length + query.length);
                        var after = msg.substring(before.length + match.length);
                        return RichText(
                          text: TextSpan(
                            text: before,
                            style: IsmChatStyles.w400Black12,
                            children: [
                              TextSpan(
                                text: match,
                                style: TextStyle(
                                  color: IsmChatConfig.chatTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: after,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
