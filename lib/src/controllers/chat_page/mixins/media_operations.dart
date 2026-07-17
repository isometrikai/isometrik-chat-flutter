part of '../chat_page_controller.dart';

/// Media operations mixin for IsmChatPageController.
///
/// This mixin handles media selection, image editing, cropping, painting,
/// and media sharing/saving operations.
mixin IsmChatPageMediaOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  void _cancelInFlightMediaProcessing() {
    _controller.mediaProcessingGeneration++;
    _controller.isProcessingMedia = false;
  }

  /// Gets media from gallery or file picker.
  void getMedia() async {
    _cancelInFlightMediaProcessing();
    _controller.webMedia.clear();
    _controller.assetsIndex = 0;

    final result = await IsmChatUtility.pickMedia(
      ImageSource.gallery,
      isVideoAndImage: true,
    );

    if (result.isEmpty) return;
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      final generation = _controller.mediaProcessingGeneration;
      _controller
        ..isProcessingMedia = true
        ..mediaAssetsTotal = result.where((x) => x != null).length;
      IsmChatUtility.showLoader();
      for (var x in result) {
        if (generation != _controller.mediaProcessingGeneration) {
          break;
        }
        final bytes = await x?.readAsBytes();
        final extension = x?.name.split('.').last;
        final dataSize = IsmChatUtility.formatBytes(bytes?.length ?? 0);
        final platformFile = IsmchPlatformFile(
          name: x?.name ?? '',
          size: bytes?.length,
          bytes: bytes,
          path: x?.path,
          extension: extension,
        );
        if (IsmChatConstants.videoExtensions.contains(extension)) {
          try {
            print(
                'Generating thumbnail for video: ${x?.name}, size: ${bytes?.length} bytes');
            final thumbnailBytes =
                await IsmChatBlob.getVideoThumbnailBytesWithPackage(
                    bytes ?? Uint8List(0));
            print(
                'Thumbnail generation result: ${thumbnailBytes?.length ?? 0} bytes');

            // Always add the video, even if thumbnail fails
            platformFile.thumbnailBytes = thumbnailBytes ?? Uint8List(0);
            _controller.webMedia.add(
              WebMediaModel(
                isVideo: true,
                platformFile: platformFile,
                dataSize: dataSize,
              ),
            );
            print('Video added to webMedia successfully');
          } catch (e) {
            print('Error in video thumbnail generation: $e');
            // Fallback: add video without thumbnail if thumbnail generation fails
            platformFile.thumbnailBytes = Uint8List(0);
            _controller.webMedia.add(
              WebMediaModel(
                isVideo: true,
                platformFile: platformFile,
                dataSize: dataSize,
              ),
            );
            print('Video added to webMedia with fallback (no thumbnail)');
          }
        } else {
          _controller.webMedia.add(
            WebMediaModel(
              isVideo: false,
              platformFile: platformFile,
              dataSize: dataSize,
            ),
          );
        }
        await Future<void>.delayed(Duration.zero);
      }
      if (generation == _controller.mediaProcessingGeneration) {
        _controller.isProcessingMedia = false;
      }
      IsmChatUtility.closeLoader();
    } else if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatRoute.goToRoute(IsmChatGalleryAssetsView(
        mediaXFile: result,
      ));
    }
  }

  /// Selects assets from the gallery.
  Future<void> selectAssets(List<XFile?> assetList) async {
    _controller.textEditingController.clear();
    _controller.webMedia.clear();
    _controller.assetsIndex = 0;
    final generation = _controller.mediaProcessingGeneration;
    _controller
      ..isProcessingMedia = true
      ..mediaAssetsTotal = assetList.where((file) => file != null).length;
    try {
      for (var file in assetList) {
        if (generation != _controller.mediaProcessingGeneration) {
          return;
        }
        if (file == null) {
          continue;
        }
        final bytes = await file.readAsBytes();
      var name = '';
      if (kIsWeb) {
        name = file.name;
      } else {
        name = file.path.split('/').last;
      }
      final extension = name.split('.').last;
      final dataSize = IsmChatUtility.formatBytes(bytes.length);
      final platformFile = IsmchPlatformFile(
        name: name,
        size: bytes.length,
        bytes: bytes,
        path: file.path,
        extension: extension,
      );
      if (IsmChatConstants.videoExtensions.contains(extension)) {
        try {
          print(
              'Generating thumbnail for video: $name, size: ${bytes.length} bytes');
          final thumbnailBytes =
              await IsmChatBlob.getVideoThumbnailBytesWithPackage(bytes);
          print(
              'Thumbnail generation result: ${thumbnailBytes?.length ?? 0} bytes');
          // print('Raw thumbnail bytes: ${thumbnailBytes?.take(50).toList() ?? []}'); // Commented out to avoid byte spam
          platformFile.thumbnailBytes = thumbnailBytes ?? Uint8List(0);
          _controller.webMedia.add(
            WebMediaModel(
              isVideo: true,
              platformFile: platformFile,
              dataSize: dataSize,
            ),
          );
          print('Video added to webMedia successfully');
        } catch (e) {
          print('Error in video thumbnail generation: $e');
          platformFile.thumbnailBytes = Uint8List(0);
          _controller.webMedia.add(
            WebMediaModel(
              isVideo: true,
              platformFile: platformFile,
              dataSize: dataSize,
            ),
          );
          print('Video added to webMedia with fallback (no thumbnail)');
        }
      } else {
        _controller.webMedia.add(
          WebMediaModel(
            isVideo: false,
            platformFile: platformFile,
            dataSize: dataSize,
          ),
        );
      }
        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      if (generation == _controller.mediaProcessingGeneration) {
        _controller.isProcessingMedia = false;
      }
    }
  }

  /// Updates gallery image at the specified index.
  Future<void> updateGalleryImage({
    required XFile file,
    required int selectedIndex,
  }) async {
    IsmChatUtility.showLoader();
    final bytes = await file.readAsBytes();
    final fileSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    var name = '';
    if (kIsWeb) {
      name = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      name = file.path.split('/').last;
    }
    final extension = name.split('.').last;
    _controller.webMedia[selectedIndex] = WebMediaModel(
      dataSize: fileSize,
      isVideo: false,
      platformFile: IsmchPlatformFile(
        name: name,
        bytes: bytes,
        path: file.path,
        size: bytes.length,
        extension: extension,
      ),
    );
    IsmChatUtility.closeLoader();
  }

  /// Crops an image.
  Future<void> cropImage({
    required String url,
    bool forGalllery = false,
    int selectedIndex = 0,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: url,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      if (forGalllery) {
        await _controller.updateGalleryImage(
            file: XFile(croppedFile.path), selectedIndex: selectedIndex);
      } else {
        await _controller.updateImage(XFile(croppedFile.path));
      }
    }
  }

  /// Paints an image.
  Future<void> paintImage({
    required String url,
    bool forGalllery = false,
    int selectedIndex = 0,
  }) async {
    final file = await IsmChatRoute.goToRoute<XFile>(
      IsmChatImagePaintView(
        file: XFile(url),
      ),
    );

    if (file == null) return;
    if (forGalllery) {
      await _controller.updateGalleryImage(
          file: XFile(file.path), selectedIndex: selectedIndex);
    } else {
      await _controller.updateImage(XFile(file.path));
    }
  }

  /// Updates the image file.
  Future<void> updateImage(XFile file) async {
    IsmChatUtility.showLoader();
    var bytes = await file.readAsBytes();
    bytes = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 60,
    );
    final fileSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    var name = '';
    if (kIsWeb) {
      name = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      name = file.path.split('/').last;
    }
    final extension = name.split('.').last;
    _controller.webMedia
      ..clear()
      ..add(
        WebMediaModel(
          dataSize: fileSize,
          isVideo: false,
          platformFile: IsmchPlatformFile(
            name: name,
            bytes: bytes,
            path: file.path,
            size: bytes.length,
            extension: extension,
          ),
        ),
      );
    IsmChatUtility.closeLoader();
  }

  /// Shares media from a message.
  Future<void> shareMedia(IsmChatMessageModel message) async {
    IsmChatUtility.showLoader();
    final path = await IsmChatUtility.makeDirectoryWithUrl(
        urlPath: message.attachments?.first.mediaUrl ?? '',
        fileName: message.attachments?.first.name ?? '');
    if (path.path.isNotEmpty) {
      final file = XFile(path.path);
      IsmChatUtility.closeLoader();
      final result = await SharePlus.instance.share(ShareParams(
        files: [file],
      ));
      if (result.status == ShareResultStatus.success) {
        IsmChatUtility.showToast('Share your media');
        IsmChatLog.success('File shared: ${result.status}');
        IsmChatRoute.goBack();
      }
    } else {
      IsmChatUtility.closeLoader();
    }
  }

  /// Saves media from a message to device.
  Future<void> saveMedia(IsmChatMessageModel message) async {
    await WidgetsBinding.instance.endOfFrame;

    final attachment = message.attachments?.firstOrNull;
    if (attachment == null) return;

    final extension = (attachment.extension ?? '').toLowerCase();
    final mimeType = (attachment.mimeType ?? '').toLowerCase();
    final isVideoMessage = message.customType == IsmChatCustomMessageType.video ||
        attachment.attachmentType == IsmChatMediaType.video;
    final isImageMessage = message.customType == IsmChatCustomMessageType.image ||
        attachment.attachmentType == IsmChatMediaType.image ||
        attachment.attachmentType == IsmChatMediaType.gif;
    final isAudioMessage = message.customType == IsmChatCustomMessageType.audio ||
        attachment.attachmentType == IsmChatMediaType.audio;
    // Message/attachment type wins over extension overlap (e.g. mp4 is in both lists).
    final isVideo = isVideoMessage ||
        mimeType.startsWith('video/') ||
        (!isAudioMessage &&
            !isImageMessage &&
            IsmChatConstants.videoExtensions.contains(extension));
    final isImage = isImageMessage ||
        mimeType.startsWith('image/') ||
        (!isAudioMessage &&
            !isVideoMessage &&
            IsmChatConstants.imageExtensions.contains(extension));
    final isAudio = isAudioMessage ||
        mimeType.startsWith('audio/') ||
        (!isVideoMessage &&
            !isImageMessage &&
            IsmChatConstants.audioExtensions.contains(extension));
    final isGalleryMedia = !isAudio && (isVideo || isImage);
    final resolvedExtension = extension.isNotEmpty
        ? extension
        : isVideo
            ? 'mp4'
            : 'jpg';
    final mediaUrl = attachment.mediaUrl ?? '';

    var showedLoader = false;
    try {
      if (!isGalleryMedia) {
        final isNetwork = mediaUrl.isValidUrl;
        if (isNetwork) {
          IsmChatUtility.showLoader();
          showedLoader = true;
        }

        await IsmChatUtility.saveFileToDevice(
          url: mediaUrl,
          fileName: IsmChatUtility.resolveSaveFileName(
            fileName: attachment.name ?? '',
            url: mediaUrl,
            extension: extension,
          ),
        );
        return;
      }

      final toAlbum = !isVideo || kIsWeb || !Platform.isAndroid;
      final hasGalleryAccess = await IsmChatUtility.requestForGallery(
        toAlbum: toAlbum,
      );
      if (!hasGalleryAccess) {
        IsmChatUtility.showToast('Gallery permission required');
        return;
      }

      IsmChatUtility.showLoader();
      showedLoader = true;

      if (mediaUrl.isValidUrl) {
        await IsmChatUtility.downloadMediaFromNetworkPath(
          url: mediaUrl,
          isVideo: isVideo,
          fileName: attachment.name ?? '',
          extension: resolvedExtension,
          downloadProgrees: (_) {},
        );
      } else {
        await IsmChatUtility.downloadMediaFromLocalPath(
          url: mediaUrl,
          isVideo: isVideo,
        );
      }
    } catch (e, st) {
      IsmChatLog.error('saveMedia error: $e', st);
      IsmChatUtility.showToast('Unable to save media');
    } finally {
      if (showedLoader) {
        IsmChatUtility.closeLoader();
      }
    }
  }
}
