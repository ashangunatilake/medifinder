
class TFirebaseException implements Exception {
  final String message;

  TFirebaseException(this.message);

  @override
  String toString() => 'TFirebaseException: $message';
}

class TFormatException implements Exception {
  final String message;

  const TFormatException([this.message = 'Invalid format encountered.']);

  @override
  String toString() => 'TFormatException: $message';
}

class TPlatformException implements Exception {
  final String message;

  TPlatformException(this.message);

  @override
  String toString() => 'TPlatformException: $message';
}
