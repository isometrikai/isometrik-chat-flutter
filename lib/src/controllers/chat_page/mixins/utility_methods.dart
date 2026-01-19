part of '../chat_page_controller.dart';

/// Utility methods mixin for IsmChatPageController.
///
/// This mixin contains helper methods and utility functions used throughout
/// the chat page controller.
mixin IsmChatPageUtilityMethodsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Gets or creates a noise widget for the specified timestamp.
  Widget getNoise(int sentAt, [bool sentByMe = true]) {
    if (!_controller.noises.keys.contains(sentAt)) {
      var color = sentByMe ? Colors.white : Colors.grey;
      var noiseList = List.generate(27, (index) => $SingleNoise(color: color));
      var noise = Noises(noises: noiseList);
      _controller.noises[sentAt] = noise;
    }
    return _controller.noises[sentAt]!;
  }

  /// Gets or creates a global key for the specified timestamp.
  GlobalKey getGlobalKey(int sentAt) {
    if (!_controller.globalKeys.keys.contains(sentAt)) {
      _controller.globalKeys[sentAt] = GlobalKey();
    }
    return _controller.globalKeys[sentAt]!;
  }

  /// Gets or creates a memory image for the specified timestamp.
  MemoryImage getMemoryImage(int sentAt, Uint8List bytes) {
    if (!_controller.memoryImage.keys.contains(sentAt)) {
      _controller.memoryImage[sentAt] = MemoryImage(bytes);
    }
    return _controller.memoryImage[sentAt] ?? MemoryImage(Uint8List(0));
  }

  /// Sorts media messages into a list of maps grouped by date.
  List<Map<String, List<IsmChatMessageModel>>> sortMediaList(
      List<IsmChatMessageModel> messages) {
    var storeMediaImageList = <Map<String, List<IsmChatMessageModel>>>[];
    for (var x in messages) {
      if (x.customType == IsmChatCustomMessageType.date) {
        storeMediaImageList.add({x.body: <IsmChatMessageModel>[]});
        continue;
      }
      storeMediaImageList.last.forEach((key, value) {
        value.add(x);
      });
    }
    return storeMediaImageList;
  }

  /// Updates the indexed message list mapping.
  ///
  /// This method is used by other mixins (e.g., get_message.dart) to update
  /// the indexed message list after messages are loaded.
  // ignore: unused_element
  void _generateIndexedMessageList() =>
      _controller.indexedMessageList = _controller.viewModel.generateIndexedMessageList(_controller.messages);
}

