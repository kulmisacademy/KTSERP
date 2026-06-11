class RegistrationData {
  const RegistrationData({
    required this.storeName,
    required this.businessType,
    required this.country,
    required this.currencyCode,
    required this.address,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.password,
    this.taxNumber,
  });

  final String storeName;
  final String businessType;
  final String country;
  final String currencyCode;
  final String address;
  final String ownerName;
  final String email;
  final String phone;
  final String password;
  final String? taxNumber;
}
