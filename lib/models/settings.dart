class AppSettings {
  final String shopName;
  final String? pin;
  final bool pinEnabled;

  AppSettings({
    this.shopName = 'Café Rays',
    this.pin,
    this.pinEnabled = false,
  });

  AppSettings copyWith({
    String? shopName,
    String? pin,
    bool? pinEnabled,
  }) {
    return AppSettings(
      shopName: shopName ?? this.shopName,
      pin: pin ?? this.pin,
      pinEnabled: pinEnabled ?? this.pinEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'shop_name': shopName,
    'pin': pin,
    'pin_enabled': pinEnabled ? 1 : 0,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    shopName: map['shop_name'] ?? 'Café Rays',
    pin: map['pin'],
    pinEnabled: (map['pin_enabled'] ?? 0) == 1,
  );
}
