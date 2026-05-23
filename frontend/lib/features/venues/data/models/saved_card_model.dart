/// Model for a saved payment card.
class SavedCardModel {
  final String id;
  final String lastFourDigits;
  final String brand; // visa, mastercard, etc.
  final String? bankName;
  final String expiryMonth;
  final String expiryYear;

  const SavedCardModel({
    required this.id,
    required this.lastFourDigits,
    required this.brand,
    this.bankName,
    required this.expiryMonth,
    required this.expiryYear,
  });

  String get maskedNumber => '•••• •••• •••• $lastFourDigits';
  String get expiry => '$expiryMonth/$expiryYear';

  Map<String, dynamic> toJson() => {
        'id': id,
        'lastFourDigits': lastFourDigits,
        'brand': brand,
        'bankName': bankName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
      };

  factory SavedCardModel.fromJson(Map<String, dynamic> json) => SavedCardModel(
        id: json['id'] as String,
        lastFourDigits: json['lastFourDigits'] as String,
        brand: json['brand'] as String,
        bankName: json['bankName'] as String?,
        expiryMonth: json['expiryMonth'] as String,
        expiryYear: json['expiryYear'] as String,
      );
}
