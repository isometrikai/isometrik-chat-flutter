import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatContactsInfoView extends StatelessWidget {
  const IsmChatContactsInfoView({super.key, required this.contacts});

  final List<IsmChatContactMetaDatModel> contacts;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmChatConfig.chatTheme.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: IsmChatRoute.goBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                  IsmChatColors.whiteColor,
            ),
          ),
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor,
          titleSpacing: 1,
          title: Text(IsmChatStrings.contactInfo,
              style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                  IsmChatStyles.w600White18),
          centerTitle: true,
        ),
        body: SizedBox(
          height: IsmChatDimens.percentHeight(1),
          child: ListView.separated(
            padding: IsmChatDimens.edgeInsets10,
            itemBuilder: (_, index) {
              var contact = contacts[index];
              return Card(
                color: IsmChatConfig.chatTheme.cardBackgroundColor ??
                    IsmChatColors.whiteColor,
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
                        style: IsmChatStyles.w600Black14,
                      ),
                      subtitle: Text(
                        contact.contactIdentifier ?? '',
                        style: IsmChatStyles.w600Black12,
                      ),
                      trailing: IsmChatTapHandler(
                        onTap: () async {
                          final opnecontact = Contact(
                              id: contact.contactId ?? '',
                              displayName: contact.contactName ?? '',
                              photo: (contact.contactImageUrl ?? '').isNotEmpty
                                  ? (contact.contactImageUrl ?? '')
                                      .strigToUnit8List
                                  : Uint8List(0),
                              phones: [
                                Phone(
                                  contact.contactIdentifier ?? '',
                                  normalizedNumber:
                                      contact.contactIdentifier ?? '',
                                )
                              ]);
                          await FlutterContacts.openExternalInsert(opnecontact);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: IsmChatDimens.seventy,
                          height: IsmChatDimens.forty,
                          decoration: BoxDecoration(
                            color: IsmChatConfig.chatTheme.primaryColor,
                            borderRadius:
                                BorderRadius.circular(IsmChatDimens.twenty),
                          ),
                          child: Text(
                            'Add',
                            style: IsmChatStyles.w600White14,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
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
                              color: IsmChatConfig.chatTheme.primaryColor,
                              size: IsmChatDimens.twentyFive,
                            ),
                            label: const Text(
                              'SMS',
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
                              color: IsmChatConfig.chatTheme.primaryColor,
                              size: IsmChatDimens.twentyFive,
                            ),
                            label: const Text('Call'),
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
