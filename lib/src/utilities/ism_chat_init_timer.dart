import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/src/utilities/chat_log.dart';

/// Stopwatch helper for profiling SDK / chat initialization (debug builds only).
///
/// Reuse this anywhere init latency needs to be measured — e.g.
/// `IsmChat.i.initialize`, chat-list mount, or opening a conversation.
///
/// Log filter: `[InitTimer]`
///
/// Example:
/// ```dart
/// final timer = IsmChatInitTimer('SDK.initialize');
/// timer.checkpoint('database ready');
/// timer.finish('mqtt connected');
/// ```
class IsmChatInitTimer {
  IsmChatInitTimer(
    this.scope, {
    String? context,
  })  : _label = context == null || context.isEmpty ? scope : '$scope [$context]',
        _startedAt = DateTime.now();

  final String scope;
  final String _label;
  final DateTime _startedAt;
  int _lastCheckpointMs = 0;
  bool _finished = false;

  /// Logs elapsed time since the previous checkpoint (or start).
  void checkpoint(String step) {
    if (!kDebugMode || _finished) return;
    final totalMs = DateTime.now().difference(_startedAt).inMilliseconds;
    final stepMs = totalMs - _lastCheckpointMs;
    _lastCheckpointMs = totalMs;
    IsmChatLog.info(
      '[InitTimer] $_label | $step | +${stepMs}ms | total ${totalMs}ms',
    );
  }

  /// Logs total elapsed time. Safe to call more than once (subsequent calls ignored).
  void finish([String? note]) {
    if (!kDebugMode || _finished) return;
    _finished = true;
    final totalMs = DateTime.now().difference(_startedAt).inMilliseconds;
    final suffix = note == null || note.isEmpty ? '' : ' — $note';
    IsmChatLog.success(
      '[InitTimer] $_label | DONE$suffix | ${totalMs}ms',
    );
  }
}
