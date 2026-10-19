
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class DataSourceException extends AppException {
  const DataSourceException(super.message);
}

final class PaymentException extends AppException {
  const PaymentException(super.message);
}
