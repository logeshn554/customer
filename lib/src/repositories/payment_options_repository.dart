import 'package:flutter_riverpod/flutter_riverpod.dart';

// BACKEND-NEEDED: Payment options, UPI apps, saved cards, wallet balance and coupon validation APIs

class UpiAppInfo {
  final String id;
  final String name;
  final String packageName;
  final String? iconUrl;

  const UpiAppInfo({
    required this.id,
    required this.name,
    required this.packageName,
    this.iconUrl,
  });
}

class SavedCardInfo {
  final String id;
  final String last4;
  final String brand; // Visa, Mastercard, RuPay
  final String expiry;

  const SavedCardInfo({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
  });
}

class CouponInfo {
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final double minOrderValue;

  const CouponInfo({
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.minOrderValue,
  });
}

class CouponValidationResult {
  final bool isValid;
  final double discountAmount;
  final String? message;

  const CouponValidationResult({
    required this.isValid,
    this.discountAmount = 0.0,
    this.message,
  });
}

abstract class PaymentOptionsRepository {
  Future<List<UpiAppInfo>> getInstalledUpiApps();
  Future<List<SavedCardInfo>> getSavedCards();
  Future<CouponValidationResult> validateCoupon(String code, double orderTotal);
  Future<List<CouponInfo>> getAvailableCoupons();
  Future<double> getWalletBalance();
}

class MockPaymentOptionsRepository implements PaymentOptionsRepository {
  @override
  Future<List<UpiAppInfo>> getInstalledUpiApps() async {
    return const [
      UpiAppInfo(id: 'gpay', name: 'Google Pay', packageName: 'com.google.android.apps.nbu.paisa.user'),
      UpiAppInfo(id: 'phonepe', name: 'PhonePe', packageName: 'com.phonepe.app'),
      UpiAppInfo(id: 'paytm', name: 'Paytm UPI', packageName: 'net.one97.paytm'),
      UpiAppInfo(id: 'cred', name: 'CRED UPI', packageName: 'com.dreamplug.androidapp'),
    ];
  }

  @override
  Future<List<SavedCardInfo>> getSavedCards() async {
    return const [
      SavedCardInfo(id: 'card-1', last4: '4242', brand: 'Visa', expiry: '12/28'),
      SavedCardInfo(id: 'card-2', last4: '8812', brand: 'Mastercard', expiry: '09/27'),
    ];
  }

  @override
  Future<CouponValidationResult> validateCoupon(String code, double orderTotal) async {
    final normalized = code.trim().toUpperCase();
    if (normalized == 'ALLGO50') {
      if (orderTotal < 199) {
        return const CouponValidationResult(isValid: false, message: 'Minimum order value of ₹199 required for ALLGO50');
      }
      return const CouponValidationResult(isValid: true, discountAmount: 50.0, message: '₹50 discount applied!');
    } else if (normalized == 'SUPER100') {
      if (orderTotal < 399) {
        return const CouponValidationResult(isValid: false, message: 'Minimum order value of ₹399 required for SUPER100');
      }
      return const CouponValidationResult(isValid: true, discountAmount: 100.0, message: '₹100 discount applied!');
    }
    return const CouponValidationResult(isValid: false, message: 'Invalid or expired coupon code');
  }

  @override
  Future<List<CouponInfo>> getAvailableCoupons() async {
    return const [
      CouponInfo(
        code: 'ALLGO50',
        title: 'Flat ₹50 OFF',
        description: 'Get ₹50 off on orders above ₹199',
        discountAmount: 50.0,
        minOrderValue: 199.0,
      ),
      CouponInfo(
        code: 'SUPER100',
        title: 'Super Saver ₹100 OFF',
        description: 'Save ₹100 on multi-store orders above ₹399',
        discountAmount: 100.0,
        minOrderValue: 399.0,
      ),
    ];
  }

  @override
  Future<double> getWalletBalance() async {
    return 250.0;
  }
}

final paymentOptionsRepositoryProvider = Provider<PaymentOptionsRepository>((ref) {
  return MockPaymentOptionsRepository();
});
