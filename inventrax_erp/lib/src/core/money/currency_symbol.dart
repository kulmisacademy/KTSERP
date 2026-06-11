/// Maps ISO currency codes to display symbols for receipts and settings.
String currencySymbolFor(String currencyCode) {
  return switch (currencyCode.toUpperCase()) {
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'KES' => 'KSh ',
    'SOS' => 'Sh ',
    _ => '$currencyCode ',
  };
}
