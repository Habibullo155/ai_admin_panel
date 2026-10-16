import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_admin_panel/app.dart';

void main() {
  testWidgets('app builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
