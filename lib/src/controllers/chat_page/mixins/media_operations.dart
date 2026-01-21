part of '../chat_page_controller.dart';

/// Media operations mixin for IsmChatPageController.
///
/// This mixin handles media selection, image editing, cropping, painting,
/// and media sharing/saving operations.
mixin IsmChatPageMediaOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Gets media from gallery or file picker.
  void getMedia() async {
    _controller.webMedia.clear();
    _controller.assetsIndex = 0;

    final result = await IsmChatUtility.pickMedia(
      ImageSource.gallery,
      isVideoAndImage: true,
    );

    if (result.isEmpty) return;
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatUtility.showLoader();
      for (var x in result) {
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
          final thumbnailBytes =
              await IsmChatBlob.getVideoThumbnailBytes(bytes ?? Uint8List(0));
          if (thumbnailBytes != null) {
            platformFile.thumbnailBytes = thumbnailBytes;
            _controller.webMedia.add(
              WebMediaModel(
                isVideo: true,
                platformFile: platformFile,
                dataSize: dataSize,
              ),
            );
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
    for (var file in assetList) {
      final bytes = await file?.readAsBytes();
      var name = '';
      if (kIsWeb) {
        name = file?.name ?? '';
      } else {
        name = (file?.path ?? '').split('/').last;
      }
      final extension = name.split('.').last;
      final dataSize = IsmChatUtility.formatBytes(bytes?.length ?? 0);
      final platformFile = IsmchPlatformFile(
        name: name,
        size: bytes?.length,
        bytes: bytes,
        path: file?.path,
        extension: extension,
      );
      if (IsmChatConstants.videoExtensions.contains(extension)) {
        final thumbnailBytes =
            await IsmChatBlob.getVideoThumbnailBytes(bytes ?? Uint8List(0));
        if (thumbnailBytes != null) {
          platformFile.thumbnailBytes = thumbnailBytes;
          _controller.webMedia.add(
            WebMediaModel(
              isVideo: true,
              platformFile: platformFile,
              dataSize: dataSize,
            ),
          );
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
    await IsmChatUtility.requestForGallery();
    if ((message.attachments?.first.mediaUrl ?? '').isValidUrl) {
      _controller.mediaDownloadProgress = 0;
      _controller.snackBarController = Get.showSnackbar(
        GetSnackBar(
          messageText: Obx(() => CustomeSnackBar(
                downloadProgress: _controller.mediaDownloadProgress,
                downloadedFileCount: 1,
                noOfFiles: 1,
              )),
        ),
      );
      if (IsmChatConstants.videoExtensions
          .contains(message.attachments?.first.extension)) {
        await IsmChatUtility.downloadMediaFromNetworkPath(
          url: message.attachments?.first.mediaUrl ?? '',
          isVideo: true,
          downloadProgrees: (value) {
            _controller.mediaDownloadProgress = value;
          },
        );
      } else {
        await IsmChatUtility.downloadMediaFromNetworkPath(
          url: message.attachments?.first.mediaUrl ?? '',
          downloadProgrees: (value) {
            _controller.mediaDownloadProgress = value;
          },
        );
      }
      if (_controller.snackBarController != null) {
        await _controller.snackBarController?.close();
      }
    } else {
      if (IsmChatConstants.videoExtensions
          .contains(message.attachments?.first.extension)) {
        await IsmChatUtility.downloadMediaFromLocalPath(
          url: message.attachments?.first.mediaUrl ?? '',
          isVideo: true,
        );
      } else {
        await IsmChatUtility.downloadMediaFromLocalPath(
          url: message.attachments?.first.mediaUrl ?? '',
        );
      }
    }
  }
}


