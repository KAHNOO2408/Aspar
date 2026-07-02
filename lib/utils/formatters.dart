String formatAmount(double amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final intPart = absAmount.toStringAsFixed(0);

  final buffer = StringBuffer();
  final reversed = intPart.split('').reversed.toList();

  for (int i = 0; i < reversed.length; i++) {
    if (i != 0 && i % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(reversed[i]);
  }

  final result = buffer.toString().split('').reversed.join('');
  return isNegative ? '-$result' : result;
}
