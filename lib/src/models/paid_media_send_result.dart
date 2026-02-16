/// Result of the paid media send delegate callback.
///
/// When [handled] is true, the app handled the media and the SDK will not send.
/// When [handled] is false, the SDK continues with the normal upload-and-send flow.
/// If [metaData] is provided, it is passed as the message metadata for each media sent.
class PaidMediaSendResult {
  const PaidMediaSendResult({
    required this.handled,
    this.metaData,
  });

  /// True if the delegate handled the media (SDK will not send).
  /// False to let the SDK continue with upload and send, optionally with [metaData].
  final bool handled;

  /// Optional metadata to pass with the message. Passed directly as the message metaData.
  final Map<String, dynamic>? metaData;

  /// Delegate handled the media; SDK will not send.
  const PaidMediaSendResult.handled()
      : handled = true,
        metaData = null;

  /// SDK should send; optionally pass [metaData] with the message.
  const PaidMediaSendResult.send([this.metaData]) : handled = false;
}
