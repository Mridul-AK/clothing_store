int toCents(double amount) => (amount * 100).round();

String formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDateTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)} ${_months[value.month - 1]} ${value.year}, '
      '${two(value.hour)}:${two(value.minute)}';
}
