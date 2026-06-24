import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Shared contacts detail screen.
///
/// Uses [IsmChatThemeResolver.contactInfoFromConfig]; omit [IsmChatPageTheme.contactInfoTheme]
/// in app config for SDK defaults. Uses [Theme.of] via [IsmChatThemeResolver].
class IsmChatContactsInfoView extends StatelessWidget {
  const IsmChatContactsInfoView({super.key, required this.contacts});

  final List<IsmChatContactMetaDatModel> contacts;

  @override
  Widget build(BuildContext context) {
    final contactTheme = IsmChatThemeResolver.contactInfoFromConfig(context);
        final headerTheme = IsmChatConfig.chatTheme.chatPageHeaderTheme;
        return Scaffold(
          backgroundColor: contactTheme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: headerTheme?.elevation ?? 0,
            leading: IconButton(
              onPressed: IsmChatRoute.goBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: headerTheme?.iconColor ??
                    IsmChatColors.primaryColorLight,
              ),
            ),
            backgroundColor: headerTheme?.backgroundColor ??
                contactTheme.scaffoldBackgroundColor,
            titleSpacing: 1,
            title: Text(
              IsmChatStrings.contactInfo,
              style: headerTheme?.titleStyle ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? IsmChatStyles.w400White14
                      : IsmChatStyles.w400Black14),
            ),
            centerTitle: true,
          ),
          body: SizedBox(
            height: IsmChatDimens.percentHeight(1),
            child: ListView.separated(
              padding: IsmChatDimens.edgeInsets10,
              itemBuilder: (_, index) {
                var contact = contacts[index];
                return Card(
                  color: contactTheme.cardBackgroundColor,
                  child: Column(
                    children: [
                      ListTile(
                        leading: IsmChatImage.profile(
                          contact.contactImageUrl ?? '',
                          name: contact.contactName,
                          isNetworkImage: false,
                          isBytes: true,
                        ),
                        title: Text(
                          contact.contactName ?? '',
                          style: contactTheme.nameTextStyle,
                        ),
                        subtitle: Text(
                          contact.contactIdentifier ?? '',
                          style: contactTheme.identifierTextStyle,
                        ),
                        trailing: IsmChatTapHandler(
                          onTap: contact.openExternalInsert,
                          child: Container(
                            alignment: Alignment.center,
                            width: IsmChatDimens.seventy,
                            height: IsmChatDimens.forty,
                            decoration: BoxDecoration(
                              color: contactTheme.addButtonBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                  IsmChatDimens.twenty),
                            ),
                            child: Text(
                              'Add',
                              style: contactTheme.addButtonTextStyle,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: contactTheme.dividerColor,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () async {
                                IsmChatUtility.toSMS(
                                    contact.contactIdentifier ?? '');
                              },
                              icon: Icon(
                                Icons.message_rounded,
                                color: contactTheme.actionIconColor,
                                size: IsmChatDimens.twentyFive,
                              ),
                              label: Text(
                                'SMS',
                                style: contactTheme.actionLabelTextStyle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () async {
                                IsmChatUtility.dialNumber(
                                  contact.contactIdentifier ?? '',
                                );
                              },
                              icon: Icon(
                                Icons.call_outlined,
                                color: contactTheme.actionIconColor,
                                size: IsmChatDimens.twentyFive,
                              ),
                              label: Text(
                                'Call',
                                style: contactTheme.actionLabelTextStyle,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (_, index) => IsmChatDimens.boxHeight10,
              itemCount: contacts.length,
            ),
          ),
        );
  }
}
