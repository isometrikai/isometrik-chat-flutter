import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatRouteManagement {
  const IsmChatRouteManagement._();

  static void goToChatPage() {
    Get.toNamed(IsmChatPageView.route);
  }

  static void goToBroadcastMessagePage({bool isBroadcast = false}) {
    Get.toNamed(IsmChatBoradcastMessagePage.route, arguments: {
      'isBroadcast': isBroadcast,
    });
  }

  static void goToOpenChatMessagePage({bool isBroadcast = false}) {
    Get.toNamed(IsmChatOpenChatMessagePage.route, arguments: {
      'isBroadcast': isBroadcast,
    });
  }

  static void goToCreateChat({
    required bool isGroupConversation,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
  }) {
    Get.toNamed(IsmChatCreateConversationView.route, arguments: {
      'isGroupConversation': isGroupConversation,
      'conversationType': conversationType
    });
  }

  static void goToBlockView() {
    Get.toNamed(IsmChatBlockedUsersView.route);
  }

  static void goToBroadcastListView() {
    Get.toNamed(IsmChatBroadCastView.route);
  }

  static void goToEditBroadcastView(BroadcastModel broadcast) {
    Get.toNamed(
      IsmChatEditBroadcastView.route,
      arguments: broadcast,
    );
  }

  static void goToEligibleMembersView(String groupcastId) {
    Get.toNamed(
      IsmChatEligibleMembersView.route,
      arguments: groupcastId,
    );
  }

  static void goToObserverView(String conversationId) {
    Get.toNamed(IsmChatObserverUsersView.route,
        arguments: {'conversationId': conversationId});
  }

  static void goToForwardView(
      {required IsmChatMessageModel message,
      required IsmChatConversationModel conversation}) {
    Get.toNamed(IsmChatForwardView.route,
        arguments: {'message': message, 'conversation': conversation});
  }

  static void goToCreteBroadcastView() {
    Get.toNamed(IsmChatCreateBroadCastView.route);
  }

  static void goToPublicView() {
    Get.toNamed(IsmChatPublicConversationView.route);
  }

  static void goToOpenView() {
    Get.toNamed(IsmChatOpenConversationView.route);
  }

  static void goToConversationInfo() {
    Get.toNamed(IsmChatConverstaionInfoView.route);
  }

  static void goToEligibleUser() {
    Get.toNamed(IsmChatGroupEligibleUser.route);
  }

  static void goToLocation() {
    Get.toNamed(IsmChatLocationWidget.route);
  }

  static void goToMediaPreview({
    required List<IsmChatMessageModel> messageData,
    required String mediaUserName,
    required bool initiated,
    required int mediaTime,
    required int mediaIndex,
  }) {
    Get.toNamed(IsmMediaPreview.route, arguments: {
      'messageData': messageData,
      'mediaUserName': mediaUserName,
      'initiated': initiated,
      'mediaTime': mediaTime,
      'mediaIndex': mediaIndex,
    });
  }

  static void goToMessageInfo({
    required IsmChatMessageModel? message,
    required bool? isGroup,
  }) {
    Get.toNamed(IsmChatMessageInfo.route, arguments: {
      'message': message,
      'isGroup': isGroup,
    });
  }

  static void goToUserInfo(
      {required UserDetails user,
      required String conversationId,
      bool fromMessagePage = true}) {
    Get.toNamed(
      IsmChatUserInfo.route,
      arguments: {
        'user': user,
        'conversationId': conversationId,
        'fromMessagePage': fromMessagePage
      },
    );
  }

  static void goToMedia(
      {required List<IsmChatMessageModel>? mediaList,
      required List<IsmChatMessageModel>? mediaListLinks,
      required List<IsmChatMessageModel>? mediaListDocs,
      d}) {
    Get.toNamed(
      IsmMedia.route,
      arguments: {
        'mediaList': mediaList,
        'mediaListLinks': mediaListLinks,
        'mediaListDocs': mediaListDocs
      },
    );
  }

  static void goToWallpaperPreview(
      {required String? backgroundColor,
      required XFile? imagePath,
      required int? assetSrNo}) {
    Get.toNamed(IsmChatWallpaperPreview.route, arguments: {
      'backgroundColor': backgroundColor,
      'imagePath': imagePath,
      'assetSrNo': assetSrNo
    });
  }

  static void goToWebMediaMessagePreview({
    required List<IsmChatMessageModel>? messageData,
    required String? mediaUserName,
    required bool? initiated,
    required int? mediaTime,
    final int? mediaIndex,
  }) {
    Get.toNamed(IsmWebMessageMediaPreview.route, arguments: {
      'messageData': messageData,
      'mediaUserName': mediaUserName,
      'mediaTime': mediaTime,
      'mediaIndex': mediaIndex,
    });
  }

  static void goToWebMediaPreview() {
    Get.toNamed(
      WebMediaPreview.route,
    );
  }

  static void goToCameraView() {
    Get.toNamed(
      IsmChatCameraView.route,
    );
  }

  static void goToVideView({required File file}) {
    Get.toNamed(IsmChatVideoView.route, arguments: {'file': file});
  }

  static void goToContactView() {
    Get.toNamed(IsmChatContactView.route);
  }

  static void goToContactInfoView(
      {required List<IsmChatContactMetaDatModel> contacts}) {
    Get.toNamed(
      IsmChatContactsInfoView.route,
      arguments: {'contacts': contacts},
    );
  }

  static void goToSearchMessageView() {
    Get.toNamed(IsmChatSearchMessgae.route);
  }

  static void goToGlobalSearchView() {
    Get.toNamed(IsmChatGlobalSearchView.route);
  }

  static void goToMediaEditView() {
    Get.toNamed(IsmChatImageEditView.route);
  }

  static void goToGalleryAssetsView(List<XFile?> fileList) {
    Get.toNamed(IsmChatGalleryAssetsView.route, arguments: {
      'fileList': fileList,
    });
  }

  static void goToProfilePicView(UserDetails user) {
    Get.toNamed(IsmChatProfilePicView.route, arguments: {'user': user});
  }
}
