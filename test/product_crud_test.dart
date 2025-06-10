import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_acc_store1/screens/products_screen.dart';
import 'package:flutter_app_acc_store1/screens/product_detail_screen.dart';
import 'package:flutter_app_acc_store1/screens/create_product_screen.dart';
import 'mocks/mock_services.dart';

void main() {
  late MockProductService mockProductService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockProductService = MockProductService();
    mockAuthService = MockAuthService();
    mockAuthService.setAuthenticated(true);
    mockAuthService.setAdmin(true);
  });

  group('Product CRUD Tests', () {
    testWidgets('Products screen shows list of products', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProductsScreen(
            prefs: prefs,
            productService: mockProductService,
            authService: mockAuthService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Product 1'), findsOneWidget);
      expect(find.text('Test Product 2'), findsOneWidget);
    });

    testWidgets('Create new product', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        MaterialApp(
          home: CreateProductScreen(
            productService: mockProductService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'New Product');
      await tester.enterText(find.byType(TextFormField).last, 'New Description');
      
      // Submit the form - use a more specific finder
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Product'));
      await tester.pumpAndSettle();

      // Verify the product was created
      final products = await mockProductService.getProducts();
      expect(products.length, 3);
      expect(products.last.title, 'New Product');
    });

    testWidgets('Update existing product', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailScreen(
            productId: 1,
            prefs: prefs,
            productService: mockProductService,
            authService: mockAuthService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Update the title
      await tester.enterText(find.byType(TextFormField).first, 'Updated Product');
      
      // Save changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify the product was updated
      final product = await mockProductService.getProduct(1);
      expect(product.title, 'Updated Product');
    });

    testWidgets('Delete product', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailScreen(
            productId: 1,
            prefs: prefs,
            productService: mockProductService,
            authService: mockAuthService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Delete the product
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion - use a more general finder
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the product was deleted
      final products = await mockProductService.getProducts();
      expect(products.length, 1);
      expect(products.first.id, 2);
    });
  });
} 