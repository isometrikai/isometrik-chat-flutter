import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatObserverUsersView extends StatefulWidget {
  IsmChatObserverUsersView({super.key, String? conversationId})
      : _conversationId = conversationId ??
            (Get.arguments as Map<String, dynamic>?)?['conversationId'];

  final String _conversationId;
  static const String route = IsmPageRoutes.observerView;

  @override
  State<IsmChatObserverUsersView> createState() =>
      _IsmChatObserverUsersViewState();
}

class _IsmChatObserverUsersViewState extends State<IsmChatObserverUsersView> {
  final converstaionController = Get.find<IsmChatConversationsController>();

  Future<List<UserDetails>>? future;
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    future = converstaionController.getObservationUser(
        conversationId: widget._conversationId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: IsmChatAppBar(
          title: !isSearch
              ? Text(
                  IsmChatStrings.observer,
                  style:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                          IsmChatStyles.w600White18,
                )
              : IsmChatInputField(
                  fillColor: IsmChatConfig.chatTheme.primaryColor,
                  style: IsmChatStyles.w400White16,
                  hint: IsmChatStrings.searchUser,
                  hintStyle: IsmChatStyles.w400White16,
                  onChanged: (value) async {
                    if (value.trim().isNotEmpty) {
                      converstaionController.debounce.run(() {
                        future = converstaionController.getObservationUser(
                          conversationId: widget._conversationId,
                          searchText: value,
                          isLoading: true,
                        );
                        setState(() {});
                      });
                    }
                  },
                ),
          action: [
            IconButton(
              onPressed: () {
                isSearch = !isSearch;
                setState(() {});
                future = converstaionController.getObservationUser(
                    conversationId: widget._conversationId);
                setState(() {});
              },
              icon:
                  Icon(!isSearch ? Icons.search_rounded : Icons.close_rounded),
              color: IsmChatColors.whiteColor,
            )
          ],
        ),
        body: FutureBuilder(
          future: future,
          builder: (_, snapshot) {
            if (snapshot.data?.isNotEmpty == true) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (_, index) {
                  var user = snapshot.data![index];
                  return ListTile(
                    leading: IsmChatImage.profile(
                      user.profileUrl,
                      isNetworkImage: user.profileUrl.isValidUrl,
                    ),
                    title: Text(
                      user.userName,
                    ),
                    subtitle: Text(
                      user.userIdentifier,
                    ),
                  );
                },
              );
            }

            if (snapshot.data?.isEmpty == true) {
              return Center(
                child: Text(
                  IsmChatStrings.noUserFound,
                  style: IsmChatStyles.w600Black16,
                ),
              );
            }

            return const IsmChatLoadingDialog();
          },
        ),
      );
}
