import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/checkout/domain/checkout_validator.dart';
import 'package:mobile/features/checkout/domain/pickup_point.dart';

void main() {
  group('CheckoutValidator (SOLID SRP & LSP)', () {
    const validator = CheckoutValidator();
    final dummyPoint = PickupPoint.defaultPoints.first;

    test('returns error when pickup point is null', () {
      final error = validator.validate(
        pickupPoint: null,
        phone: '+375 29 111-22-33',
        name: 'Иван',
        surname: 'Иванов',
        email: 'ivan@example.com',
      );
      expect(error, 'Пожалуйста, выберите пункт выдачи');
    });

    test('returns error when phone is empty', () {
      final error = validator.validate(
        pickupPoint: dummyPoint,
        phone: '   ',
        name: 'Иван',
        surname: 'Иванов',
        email: 'ivan@example.com',
      );
      expect(error, 'Введите контактный номер телефона');
    });

    test('returns error when name is empty', () {
      final error = validator.validate(
        pickupPoint: dummyPoint,
        phone: '+375 29 111-22-33',
        name: '',
        surname: 'Иванов',
        email: 'ivan@example.com',
      );
      expect(error, 'Введите ваше имя');
    });

    test('returns error when surname is empty', () {
      final error = validator.validate(
        pickupPoint: dummyPoint,
        phone: '+375 29 111-22-33',
        name: 'Иван',
        surname: '   ',
        email: 'ivan@example.com',
      );
      expect(error, 'Введите вашу фамилию');
    });

    test('returns error when email is invalid or empty', () {
      final error1 = validator.validate(
        pickupPoint: dummyPoint,
        phone: '+375 29 111-22-33',
        name: 'Иван',
        surname: 'Иванов',
        email: '',
      );
      expect(error1, 'Введите корректный адрес эл. почты');

      final error2 = validator.validate(
        pickupPoint: dummyPoint,
        phone: '+375 29 111-22-33',
        name: 'Иван',
        surname: 'Иванов',
        email: 'invalid-email',
      );
      expect(error2, 'Введите корректный адрес эл. почты');
    });

    test('returns null (success) when all fields are valid', () {
      final error = validator.validate(
        pickupPoint: dummyPoint,
        phone: '+375 29 111-22-33',
        name: 'Иван',
        surname: 'Иванов',
        email: 'ivan@example.com',
      );
      expect(error, isNull);
    });
  });
}
