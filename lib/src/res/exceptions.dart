class IsmChatInvalidMapUrlException implements Exception {
  const IsmChatInvalidMapUrlException(this.message);

  final String message;

  @override
  String toString() {
    Object? message = this.message;
    return 'InvalidMapUrlException: $message';
  }
}

class IsmChatInvalidWeekdayNumber implements Exception {
  const IsmChatInvalidWeekdayNumber(this.message);

  final String message;

  @override
  String toString() {
    Object? message = this.message;
    return 'InvalidMapUrlException: $message';
  }
}
