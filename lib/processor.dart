import 'dart:math';

abstract class PaymentProcessor {
  Future<bool> processPayment(double amount);
}

class CashPaymentProcessor implements PaymentProcessor {
  @override
  Future<bool> processPayment(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

class CreditPaymentProcessor implements PaymentProcessor {
  @override
  Future<bool> processPayment(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    return Random().nextDouble() < 0.8;
  }
}