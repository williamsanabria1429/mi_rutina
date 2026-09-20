import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_rutina/main.dart';

void main() {
  testWidgets('La app arranca y muestra MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MiRutinaApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
