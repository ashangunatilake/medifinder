
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

class InsufficientQuantityException implements Exception {
  final String message;
  InsufficientQuantityException(this.message);
}

class DrugBrandNameException implements Exception {
  final String message;
  DrugBrandNameException(this.message);
}

class DrugNameException implements Exception {
  final String message;
  DrugNameException(this.message);
}

class ErrorException implements Exception {
  final String message;
  ErrorException([this.message = 'Something went wrong']);
}

class UserLoginException implements Exception {
  final String message;
  UserLoginException(this.message);
}