import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  List<Order> _orders = [];
  Map<int, Product> _products = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.getOrders();
      print('Loaded orders: ${orders.length}');
      print('All orders: ${orders.map((o) => 'Order ${o.id}: cashReceiptId=${o.cashReceiptId}').join('\n')}');
      
      // Filter out orders that have a cashReceiptId
      final pendingOrders = orders.where((order) => order.cashReceiptId == null).toList();
      print('Pending orders: ${pendingOrders.length}');
      print('Pending orders details: ${pendingOrders.map((o) => 'Order ${o.id}: cashReceiptId=${o.cashReceiptId}').join('\n')}');
      
      // Store products from orders
      final products = <int, Product>{};
      for (var order in pendingOrders) {
        if (order.product != null) {
          products[order.productId] = order.product!;
        }
      }

      setState(() {
        _orders = pendingOrders;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _orders.isEmpty
                  ? const Center(child: Text('Your cart is empty'))
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadCart,
                            child: ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final product = _products[order.productId];
                                print('Building order ${order.id}, product: ${product?.title}'); // Debug log
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: product?.imageUrls.isNotEmpty == true
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              product!.imageUrls.first,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error'); // Debug log
                                                return Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image_not_supported),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported),
                                          ),
                                    title: Text(product?.title ?? 'Loading...'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (product?.price != order.price)
                                          Text(
                                            'Original price: \$${product?.price.toStringAsFixed(2) ?? '0.00'}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        try {
                                          await _orderService.deleteOrder(order.id);
                                          setState(() {
                                            _orders.removeWhere((o) => o.id == order.id);
                                            _products.remove(order.productId);
                                          });
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Order removed from cart'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to remove order: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (_orders.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              onPressed: _checkoutAllOrders,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              icon: const Icon(Icons.shopping_cart_checkout),
                              label: const Text(
                                'Checkout All Orders',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Future<void> _checkoutAllOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all unpaid order IDs
      final unpaidOrderIds = _orders.map((order) => order.id).toList();
      print('Checking out orders: ${unpaidOrderIds.join(', ')}');

      if (unpaidOrderIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No unpaid orders to checkout'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create cash receipt for all unpaid orders
      final response = await _orderService.createCashReceipt(unpaidOrderIds);
      print('Checkout response: $response');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All orders checked out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload the cart to get fresh state from server
      await _loadCart();
    } catch (e) {
      print('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking out orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 