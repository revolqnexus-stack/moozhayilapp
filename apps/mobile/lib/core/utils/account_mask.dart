String maskBankAccount(String accountNumber) {
  final digits = accountNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) {
    return '••••';
  }
  return '••••••${digits.substring(digits.length - 4)}';
}
