class CustomException implements Exception {
  final dynamic _message;
  final dynamic _prefix;

  CustomException(this._message, this._prefix);

  @override
  String toString() {
    return "$_prefix:$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "");
}

class UnAuthorizedException extends CustomException {
  UnAuthorizedException([String? message]) : super(message, "");
}

class DoesNotExistException extends CustomException {
  DoesNotExistException([String? message]) : super(message, "");
}

class ServerValidationError extends CustomException {
  ServerValidationError([String? message]) : super(message, "");
}



class underMaintenanceError extends CustomException {
  underMaintenanceError([String? message]) : super(message, "");
}