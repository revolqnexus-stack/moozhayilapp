String maskPan(String pan) {
  final value = pan.trim().toUpperCase();
  if (value.length != 10) {
    return value;
  }

  return '${value.substring(0, 5)}••••${value.substring(9)}';
}
