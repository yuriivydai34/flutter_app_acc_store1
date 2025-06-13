import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<Order> createOrder(int productId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final requestBody = {
      'productId': productId
    };
    print('Sending request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse == null) {
          throw Exception('Empty response from server');
        }
        return Order.fromJson(jsonResponse);
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse server response: $e');
      }
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<List<Order>> getOrders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/order'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((json) => Order.fromJson(json)).toList();
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse server response: $e');
      }
    } else {
      throw Exception('Failed to get orders: ${response.body}');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}/order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete order: ${response.body}');
    }
  }
} 