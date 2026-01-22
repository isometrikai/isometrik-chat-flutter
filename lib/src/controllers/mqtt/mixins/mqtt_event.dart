// Export all sub-mixins so they can be used directly by the controller
export 'mqtt_event/block_unblock.dart';
export 'mqtt_event/broadcast.dart';
export 'mqtt_event/calls.dart';
export 'mqtt_event/conversation_operations.dart';
export 'mqtt_event/event_processing.dart';
export 'mqtt_event/group_operations.dart';
export 'mqtt_event/message_handlers.dart';
export 'mqtt_event/message_status.dart';
export 'mqtt_event/observer_operations.dart';
export 'mqtt_event/reactions.dart';
export 'mqtt_event/typing_events.dart';
export 'mqtt_event/utilities.dart';
export 'mqtt_event/variables.dart';

/// Mixin that handles MQTT events and message processing for the chat system.
///
/// This mixin acts as a type alias and documentation for the composed mixins.
/// The actual mixins are used directly by IsmChatMqttController since
/// Dart mixins cannot use `with` to compose other mixins.
///
/// The following mixins are used by the controller:
/// - Variables: State management
/// - Utilities: Helper methods
/// - Event Processing: Main event routing
/// - Message Handlers: Message processing
/// - Message Status: Delivery and read status
/// - Typing Events: Typing indicators
/// - Group Operations: Group management
/// - Conversation Operations: Conversation management
/// - Reactions: Message reactions
/// - Block/Unblock: User blocking
/// - Broadcast: Broadcast messages
/// - Observer Operations: Observer functionality
/// - Calls: One-to-one calls
mixin IsmChatMqttEventMixin {
  // This mixin is kept for backward compatibility and documentation purposes.
  // All functionality is provided by the individual mixins that are composed
  // directly in IsmChatMqttController.
}
