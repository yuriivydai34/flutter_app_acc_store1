import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app_acc_store1/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Login and navigate to products', (WidgetTester tester) async {
      // Clear any existing preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username and password fields

      // Enter login credentials
      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify we're on the products screen
      expect(find.text('Products'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Create new product', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we're on the create product screen
      expect(find.text('Create Product'), findsOneWidget);

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'Test Product');
      await tester.enterText(find.byType(TextFormField).last, 'Test Description');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Product'));
      await tester.pumpAndSettle();

      // Verify we're back on the products screen
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('View and edit product', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap on the first product
      await tester.tap(find.byType(DataRow).first);
      await tester.pumpAndSettle();

      // Verify we're on the product detail screen
      expect(find.text('Product Details'), findsOneWidget);

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Update the title
      await tester.enterText(find.byType(TextFormField).first, 'Updated Product');
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify we're back on the products screen
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Updated Product'), findsOneWidget);
    });

    testWidgets('Delete product', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Get initial product count
      final initialProductCount = find.byType(DataRow).evaluate().length;

      // Tap on the first product
      await tester.tap(find.byType(DataRow).first);
      await tester.pumpAndSettle();

      // Delete the product
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify we're back on the products screen
      expect(find.text('Products'), findsOneWidget);
      
      // Verify product count decreased
      final finalProductCount = find.byType(DataRow).evaluate().length;
      expect(finalProductCount, initialProductCount - 1);
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Verify we're back on the login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
} 