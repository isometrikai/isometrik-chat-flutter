import 'dart:convert';

import 'package:isometrik_flutter_chat/src/models/attachment_model.dart';

class AttachmentCaptionModel {
  AttachmentCaptionModel({
    required this.attachmentModel,
    required this.caption,
  });

  factory AttachmentCaptionModel.fromMap(Map<String, dynamic> map) =>
      AttachmentCaptionModel(
        attachmentModel: AttachmentModel.fromMap(
            map['attachmentModel'] as Map<String, dynamic>),
        caption: map['caption'] as String,
      );

  factory AttachmentCaptionModel.fromJson(String source) =>
      AttachmentCaptionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final AttachmentModel attachmentModel;
  final String caption;

  AttachmentCaptionModel copyWith({
    AttachmentModel? attachmentModel,
    String? caption,
  }) =>
      AttachmentCaptionModel(
        attachmentModel: attachmentModel ?? this.attachmentModel,
        caption: caption ?? this.caption,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'attachmentModel': attachmentModel.toMap(),
        'caption': caption,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AttachmentCaptionModel(attachmentModel: $attachmentModel, caption: $caption)';

  @override
  bool operator ==(covariant AttachmentCaptionModel other) {
    if (identical(this, other)) return true;

    return other.attachmentModel == attachmentModel && other.caption == caption;
  }

  @override
  int get hashCode => attachmentModel.hashCode ^ caption.hashCode;
}
