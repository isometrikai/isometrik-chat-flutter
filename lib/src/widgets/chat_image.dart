import 'dart:io';
import 'dart:typed_data';

import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:isometrik_flutter_chat/src/utilities/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatImage extends StatelessWidget {
  const IsmChatImage(
    this.imageUrl, {
    this.name,
    this.dimensions,
    this.isNetworkImage = true,
    this.isBytes = false,
    super.key,
    this.radius,
    this.backgroundColor,
  })  : _name = name ?? 'U',
        _isProfileImage = false;

  const IsmChatImage.profile(
    this.imageUrl, {
    this.name,
    this.dimensions = 48,
    this.isNetworkImage = true,
    this.isBytes = false,
    super.key,
    this.radius,
    this.backgroundColor,
  })  : _name = name ?? 'U',
        _isProfileImage = true,
        assert(dimensions != null, 'Dimensions cannot be null');

  final String imageUrl;
  final String? name;
  final Color? backgroundColor;
  final double? dimensions;
  final bool isNetworkImage;
  final double? radius;
  final bool isBytes;
  final String _name;
  final bool _isProfileImage;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: _isProfileImage ? dimensions : context.width * 0.6,
        child: ClipRRect(
          borderRadius: _isProfileImage
              ? BorderRadius.circular(dimensions! / 2)
              : BorderRadius.circular(radius ?? IsmChatDimens.eight),
          child: isNetworkImage
              ? _NetworkImage(
                  backgroundColor: backgroundColor,
                  imageUrl: imageUrl,
                  isProfileImage: _isProfileImage,
                  name: _name)
              : isBytes
                  ? _MemeroyImage(
                      backgroundColor: backgroundColor,
                      imageUrl: imageUrl,
                      name: _name,
                    )
                  : _AssetImage(
                      backgroundColor: backgroundColor,
                      imageUrl: imageUrl,
                      name: _name,
                    ),
        ),
      );
}

class _AssetImage extends StatelessWidget {
  const _AssetImage(
      {required this.imageUrl, required this.name, this.backgroundColor});
  final String imageUrl;
  final String name;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    try {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: IsmChatColors.whiteColor),
          color: backgroundColor ??
              IsmChatConfig.chatTheme.primaryColor!.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Text(
          name[0],
          style: IsmChatStyles.w600Black24.copyWith(
            color: IsmChatConfig.chatTheme.primaryColor,
          ),
        ),
      );
    }
  }
}

class _MemeroyImage extends StatelessWidget {
  const _MemeroyImage(
      {required this.imageUrl, required this.name, this.backgroundColor});
  final String imageUrl;
  final String name;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    if (imageUrl.isNotEmpty && imageUrl != 'null') {
      bytes = imageUrl.strigToUnit8List;
    }
    return bytes == null || bytes.isEmpty == true
        ? Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: IsmChatColors.whiteColor),
              color: backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor!.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              name[0],
              style: IsmChatStyles.w600Black24.copyWith(
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
            ),
          )
        : Image.memory(
            bytes,
            fit: BoxFit.cover,
          );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.imageUrl,
    required bool isProfileImage,
    required String name,
    this.backgroundColor,
  })  : _isProfileImage = isProfileImage,
        _name = name;

  final String imageUrl;
  final Color? backgroundColor;
  final bool _isProfileImage;
  final String _name;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        cacheKey: imageUrl,
        imageBuilder: (_, image) {
          try {
            if (imageUrl.isEmpty) {
              return _ErrorImage(
                backgroundColor: backgroundColor,
                isProfileImage: _isProfileImage,
                name: _name,
              );
            }
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: IsmChatColors.whiteColor),
                shape: _isProfileImage ? BoxShape.circle : BoxShape.rectangle,
                color:
                    backgroundColor ?? IsmChatConfig.chatTheme.backgroundColor!,
                image: DecorationImage(image: image, fit: BoxFit.cover),
              ),
            );
          } catch (e) {
            return _ErrorImage(
              backgroundColor: backgroundColor,
              isProfileImage: _isProfileImage,
              name: _name,
            );
          }
        },
        placeholder: (context, url) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: IsmChatColors.whiteColor),
            color: backgroundColor ??
                IsmChatConfig.chatTheme.primaryColor!.withOpacity(0.2),
            shape: _isProfileImage ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: _isProfileImage
              ? Text(
                  _name.isNotEmpty ? _name[0] : 'U',
                  style: IsmChatStyles.w600Black24.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
        ),
        errorWidget: (context, url, error) => _ErrorImage(
            backgroundColor: backgroundColor,
            isProfileImage: _isProfileImage,
            name: _name),
      );
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage({
    required bool isProfileImage,
    required String name,
    this.backgroundColor,
  })  : _isProfileImage = isProfileImage,
        _name = name;

  final bool _isProfileImage;
  final Color? backgroundColor;
  final String _name;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: IsmChatColors.whiteColor),
          color: IsmChatConfig.chatTheme.primaryColor!.withOpacity(0.2),
          shape: _isProfileImage ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: _isProfileImage
            ? Text(
                _name.isNotEmpty ? _name[0] : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: IsmChatConfig.chatTheme.primaryColor,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: IsmChatColors.greyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                ),
                alignment: Alignment.center,
                child: const Text(
                  IsmChatStrings.errorLoadingImage,
                ),
              ),
      );
}
