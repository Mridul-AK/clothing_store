import 'package:clothing_store/features/auth/domain/validators/credentials_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CredentialsValidator.validateEmail', () {
    test('accepts well-formed addresses', () {
      for (final email in [
        'demo@threadline.com',
        'first.last+tag@mail.co.uk',
        '  padded@example.org  ',
      ]) {
        expect(
          CredentialsValidator.validateEmail(email),
          isNull,
          reason: email,
        );
      }
    });

    test('rejects empty and malformed addresses', () {
      expect(CredentialsValidator.validateEmail(''), 'Email is required');
      for (final email in [
        'plain',
        'no-at.com',
        'a@b',
        'a@b.c',
        '@example.com',
        'a b@example.com',
      ]) {
        expect(
          CredentialsValidator.validateEmail(email),
          'Enter a valid email address',
          reason: email,
        );
      }
    });
  });

  group('CredentialsValidator.validatePassword', () {
    test('requires a value', () {
      expect(CredentialsValidator.validatePassword(''), 'Password is required');
    });

    test('enforces the minimum length', () {
      expect(CredentialsValidator.validatePassword('12345'), isNotNull);
      expect(CredentialsValidator.validatePassword('123456'), isNull);
    });
  });

  test('isValid needs both fields to pass', () {
    expect(
      CredentialsValidator.isValid(email: 'a@b.com', password: 'secret1'),
      isTrue,
    );
    expect(
      CredentialsValidator.isValid(email: 'a@b.com', password: '123'),
      isFalse,
    );
    expect(
      CredentialsValidator.isValid(email: 'bad', password: 'secret1'),
      isFalse,
    );
  });
}
