// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const ui.Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: Center(child: Text('smoke')))),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('smoke'), findsOneWidget);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
