import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBottomSheetAttachmentModel {
  const IsmChatBottomSheetAttachmentModel({
    required this.label,
    required this.backgroundColor,
    required this.icon,
    required this.attachmentType,
  });

  final String label;
  final Color backgroundColor;
  final IconData icon;
  final IsmChatAttachmentType attachmentType;
}
