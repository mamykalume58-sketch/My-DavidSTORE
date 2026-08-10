int parsePrice(String price) {
  return int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
}

String formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(str[i]);
  }
  return '${buffer.toString()} FC';
}
