import 'pickup_point.dart';

abstract class ICheckoutValidator {
  String? validate({
    required PickupPoint? pickupPoint,
    required String phone,
    required String name,
    required String surname,
    required String email,
  });
}

class CheckoutValidator implements ICheckoutValidator {
  const CheckoutValidator();

  @override
  String? validate({
    required PickupPoint? pickupPoint,
    required String phone,
    required String name,
    required String surname,
    required String email,
  }) {
    if (pickupPoint == null) {
      return 'Пожалуйста, выберите пункт выдачи';
    }

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isEmpty) {
      return 'Введите контактный номер телефона';
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Введите ваше имя';
    }

    final trimmedSurname = surname.trim();
    if (trimmedSurname.isEmpty) {
      return 'Введите вашу фамилию';
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Введите корректный адрес эл. почты';
    }

    return null; // Успешно
  }
}

