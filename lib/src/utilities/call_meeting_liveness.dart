import 'package:flutter/foundation.dart';

/// Session-only live / ended / connected meeting ids.
///
/// Backend message history keeps `meetingCreated` after hang-up
/// (`meetingEndedDueToNoUserPublishing`, etc.). Local DB patches of `action`
/// are wiped on logout, so after re-login every call row looks like Ringing
/// again.
///
/// Reuse from MQTT call handlers and host call tiles:
/// - [markLive] on `meetingCreated` (ringing)
/// - [markConnected] on `joinRequestAccept` (other user joined)
/// - [markEnded] on `meetingEnded*`
/// History fetch must not call [markLive].
///
/// [revision] is listened by conversation-list cards (via list rebuild) and
/// the open-chat call bubble so Ringing → In call → duration updates
/// without a new chat row.
class IsmChatCallMeetingLiveness {
  IsmChatCallMeetingLiveness._();

  static final Set<String> _live = <String>{};
  static final Set<String> _connected = <String>{};
  static final Set<String> _ended = <String>{};

  /// Bumps whenever live / connected / ended sets change.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void _bump() => revision.value++;

  static void markLive(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return;
    if (_ended.contains(id)) return;
    _live.add(id);
    _bump();
  }

  /// Other party accepted / joined (`joinRequestAccept`). Still live until hang-up.
  static void markConnected(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return;
    if (_ended.contains(id)) return;
    _live.add(id);
    _connected.add(id);
    _bump();
  }

  static void markEnded(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return;
    _live.remove(id);
    _connected.remove(id);
    _ended.add(id);
    _bump();
  }

  static bool isEnded(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return false;
    return _ended.contains(id);
  }

  /// True only for a meeting started in this app session and not yet hung up.
  static bool isLive(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return false;
    if (_ended.contains(id)) return false;
    return _live.contains(id);
  }

  /// True after `joinRequestAccept` until hang-up. Ringing tiles use this for "In call".
  static bool isConnected(String? meetingId) {
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty) return false;
    if (_ended.contains(id)) return false;
    return _connected.contains(id);
  }

  /// Call from logout so the next login does not inherit ids.
  static void clear() {
    _live.clear();
    _connected.clear();
    _ended.clear();
    _bump();
  }
}
