class IsmMqttProperties {
  IsmMqttProperties({
    this.autoReconnect = true,
    this.enableLogging = true,
    this.shouldSetupMqtt = true,
    this.topics,
    this.topicChannels,
  });

  final bool autoReconnect;
  final bool enableLogging;
  final bool shouldSetupMqtt;
  final List<String>? topics;
  final List<String>? topicChannels;
}
