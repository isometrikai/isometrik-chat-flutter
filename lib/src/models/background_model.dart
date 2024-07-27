// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmChatBackgroundModel {
  final bool isImage;
  final String? color;
  final String? imageUrl;
  final int? srNoBackgroundAssset;
  IsmChatBackgroundModel({
    required this.isImage,
    this.color,
    this.imageUrl,
    this.srNoBackgroundAssset,
  });

  IsmChatBackgroundModel copyWith({
    bool? isImage,
    String? color,
    String? imageUrl,
    int? srNoBackgroundAssset,
  }) =>
      IsmChatBackgroundModel(
        isImage: isImage ?? this.isImage,
        color: color ?? this.color,
        imageUrl: imageUrl ?? this.imageUrl,
        srNoBackgroundAssset: srNoBackgroundAssset ?? this.srNoBackgroundAssset,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isImage': isImage,
        'color': color,
        'imageUrl': imageUrl,
        'srNoBackgroundAssset': srNoBackgroundAssset,
      };

  factory IsmChatBackgroundModel.fromMap(Map<String, dynamic> map) =>
      IsmChatBackgroundModel(
        isImage: map['isImage'] as bool? ?? false,
        color: map['color'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        srNoBackgroundAssset: map['srNoBackgroundAssset'] != null
            ? map['srNoBackgroundAssset'] as int
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmChatBackgroundModel.fromJson(String source) =>
      IsmChatBackgroundModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmChatBackgroundModel(isImage: $isImage, color: $color, imageUrl: $imageUrl, srNoBackgroundAssset: $srNoBackgroundAssset)';

  @override
  bool operator ==(covariant IsmChatBackgroundModel other) {
    if (identical(this, other)) return true;

    return other.isImage == isImage &&
        other.color == color &&
        other.imageUrl == imageUrl &&
        other.srNoBackgroundAssset == srNoBackgroundAssset;
  }

  @override
  int get hashCode =>
      isImage.hashCode ^
      color.hashCode ^
      imageUrl.hashCode ^
      srNoBackgroundAssset.hashCode;
}

class AssetsModel {
  final List<BackGroundAsset> images;
  final List<BackGroundAsset> colors;
  AssetsModel({
    required this.images,
    required this.colors,
  });

  AssetsModel copyWith({
    List<BackGroundAsset>? images,
    List<BackGroundAsset>? colors,
  }) =>
      AssetsModel(
        images: images ?? this.images,
        colors: colors ?? this.colors,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'images': images.map((x) => x.toMap()).toList(),
        'colors': colors.map((x) => x.toMap()).toList(),
      };

  factory AssetsModel.fromMap(Map<String, dynamic> map) => AssetsModel(
        images: List<BackGroundAsset>.from(
          (map['images'] as List).map<BackGroundAsset>(
            (x) => BackGroundAsset.fromMap(x as Map<String, dynamic>),
          ),
        ),
        colors: List<BackGroundAsset>.from(
          (map['colors'] as List).map<BackGroundAsset>(
            (x) => BackGroundAsset.fromMap(x as Map<String, dynamic>),
          ),
        ),
      );

  String toJson() => json.encode(toMap());

  factory AssetsModel.fromJson(String source) =>
      AssetsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AssetsModel(images: $images, colors: $colors)';

  @override
  bool operator ==(covariant AssetsModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.images, images) && listEquals(other.colors, colors);
  }

  @override
  int get hashCode => images.hashCode ^ colors.hashCode;
}

class BackGroundAsset {
  final String? color;
  final int? srNo;
  final String? path;
  BackGroundAsset({
    this.color,
    this.srNo,
    this.path,
  });

  BackGroundAsset copyWith({
    String? color,
    int? srNo,
    String? path,
  }) =>
      BackGroundAsset(
        color: color ?? this.color,
        srNo: srNo ?? this.srNo,
        path: path ?? this.path,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'color': color,
        'srNo': srNo,
        'path': path,
      };

  factory BackGroundAsset.fromMap(Map<String, dynamic> map) => BackGroundAsset(
        color: map['color'] != null ? map['color'] as String : null,
        srNo: map['srNo'] != null ? map['srNo'] as int : null,
        path: map['path'] != null ? map['path'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory BackGroundAsset.fromJson(String source) =>
      BackGroundAsset.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BackGroundAsset(color: $color, srNo: $srNo, path: $path)';

  @override
  bool operator ==(covariant BackGroundAsset other) {
    if (identical(this, other)) return true;

    return other.color == color && other.srNo == srNo && other.path == path;
  }

  @override
  int get hashCode => color.hashCode ^ srNo.hashCode ^ path.hashCode;
}
