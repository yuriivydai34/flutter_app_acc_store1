// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_acc_store1/main.dart';

void main() {
  group('App Initialization', () {
    testWidgets('App initializes and shows store front', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Welcome to the Store!'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Profile button navigates to profile screen', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Logout button exists on store front', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses Material 3 theme', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}
