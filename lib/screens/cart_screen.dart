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
      final pendingOrders = orders.where((order) => order.cashReceiptId == null).toList();
      print('Pending orders: ${pendingOrders.length}');
      
      // Store products from orders
      for (var order in pendingOrders) {
        if (order.product != null) {
          setState(() {
            _products[order.productId] = order.product!;
          });
        }
      }

      setState(() {
        _orders = pendingOrders;
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
                  : RefreshIndicator(
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
                              subtitle: Text('\$${product?.price.toStringAsFixed(2) ?? '0.00'}'),
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
    );
  }
} 