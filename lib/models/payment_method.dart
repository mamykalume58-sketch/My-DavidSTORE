import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String provider; // 'M-Pesa', 'Airtel Money', 'Orange Money'
  final String phoneNumber; // format complet, ex: +243812345678
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.provider,
    required this.phoneNumber,
    required this.isDefault,
  });

  factory PaymentMethod.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PaymentMethod(
      id: doc.id,
      provider: data['provider'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  String get logoAsset {
    switch (provider) {
      case 'M-Pesa':
        return 'assets/images/mpesa_logo.png';
      case 'Airtel Money':
        return 'assets/images/airtel_money_logo.png';
      case 'Orange Money':
        return 'assets/images/orange_money_logo.png';
      default:
        return '';
    }
  }
}
