import 'package:mqtt_client/mqtt_client.dart';

// Define a type alias for a map with dynamic values.
/// A map with string keys and dynamic values.
/// This type alias is used to represent a map where the keys are strings and the values can be of any type.
typedef DynamicMap = Map<String, dynamic>;

// Define a type alias for an MQTT payload.
/// A list of MQTT received messages with optional MQTT messages.
/// This type alias is used to represent a list of MQTT received messages, where each message may or may not contain an MQTT message.
typedef MqttHelperPayload = List<MqttReceivedMessage<MqttMessage?>>;
