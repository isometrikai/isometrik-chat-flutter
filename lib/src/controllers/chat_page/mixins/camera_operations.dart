part of '../chat_page_controller.dart';

/// Camera operations mixin for IsmChatPageController.
///
/// This mixin handles camera initialization, toggling, permissions,
/// and photo capture functionality.
mixin IsmChatPageCameraOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Initializes the camera for use.
  Future<bool> initializeCamera() async {
    try {
      _controller._cameras = await availableCameras();
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied') {
        await IsmChatContextWidget.showDialogContext(
          content: const IsmChatAlertDialogBox(
            title: IsmChatStrings.cameraPermissionBlock,
            cancelLabel: IsmChatStrings.okay,
          ),
        );
      }
      return false;
    }

    if (_controller._cameras.isNotEmpty) {
      return _controller.toggleCamera();
    }
    return true;
  }

  /// Toggles between front and back camera.
  Future<bool> toggleCamera() async {
    _controller.areCamerasInitialized = false;

    if (!IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      _controller.isFrontCameraSelected = !_controller.isFrontCameraSelected;
    }

    if (_controller.isFrontCameraSelected) {
      _controller._frontCameraController = CameraController(
        _controller._cameras[1],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    } else {
      _controller._backCameraController = CameraController(
        _controller._cameras[0],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    }

    try {
      await _controller.cameraController.initialize();
    } on CameraException catch (e) {
      if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context) &&
          kIsWeb) {
        final state = await IsmChatBlob.checkPermission('microphone');
        if (state == 'denied') {
          unawaited(IsmChatContextWidget.showDialogContext(
            content: const IsmChatAlertDialogBox(
              title: IsmChatStrings.micePermissionBlock,
              cancelLabel: IsmChatStrings.okay,
            ),
          ));
          return false;
        }
      } else {
        IsmChatLog.error(
            'Camera permission error ${e.code} == ${e.description}');
        await AppSettings.openAppSettings();
        await _controller.checkCameraPermission();
      }
    }
    await _controller.checkCameraPermission();
    return true;
  }

  /// Checks camera permission status.
  Future<void> checkCameraPermission() async {
    if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
            IsmChatConfig.context) &&
        kIsWeb) {
      final state = await IsmChatBlob.checkPermission('camera');
      if (state == 'granted') {
        _controller.areCamerasInitialized = true;
      } else {
        _controller.areCamerasInitialized = false;
      }
    } else {
      if (await Permission.camera.isGranted) {
        _controller.areCamerasInitialized = true;
      } else {
        _controller.areCamerasInitialized = false;
      }
    }
  }

  /// Toggles the camera flash mode.
  void toggleFlash([FlashMode? mode]) {
    if (mode != null) {
      _controller.flashMode = mode;
    } else {
      if (_controller.flashMode == FlashMode.off) {
        _controller.flashMode = FlashMode.always;
      } else if (_controller.flashMode == FlashMode.always) {
        _controller.flashMode = FlashMode.auto;
      } else if (_controller.flashMode == FlashMode.auto) {
        _controller.flashMode = FlashMode.off;
      } else {
        _controller.flashMode = FlashMode.torch;
      }
    }
    _controller.cameraController.setFlashMode(_controller.flashMode);
  }

  /// Takes a photo using the camera.
  void takePhoto() async {
    final file = await _controller.cameraController.takePicture();
    XFile? mainFile;
    if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatRoute.goBack();
    }

    if (_controller.cameraController.description.lensDirection ==
        CameraLensDirection.front) {
      final imageBytes = await file.readAsBytes();
      final file2 = File(file.path);
      final originalImage = img.decodeImage(imageBytes);
      final fixedImage = img.flipHorizontal(originalImage!);
      final fixedFile = await file2.writeAsBytes(
        img.encodeJpg(fixedImage),
        flush: true,
      );
      mainFile = XFile(
        fixedFile.path,
      );
    } else {
      mainFile = XFile(file.path);
    }

    await _controller.updateImage(mainFile);
    if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatRoute.goToRoute(const IsmChatImageEditView());
    }
  }
}

