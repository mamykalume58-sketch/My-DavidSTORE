import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:davidstore/app.dart';

void main() {
  testWidgets('App lance correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const DavidStoreApp());
    await tester.pump();
  });
}
