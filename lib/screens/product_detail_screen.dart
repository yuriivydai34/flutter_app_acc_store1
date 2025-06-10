import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final SharedPreferences prefs;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.prefs,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploading = false;
  String? _errorMessage;
  Product? _product;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productService.getProduct(widget.productId);
      setState(() {
        _product = product;
        _titleController.text = product.title;
        _descriptionController.text = product.description;
        _imageUrls = product.imageUrls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = '${dotenv.env['API_URL']}/files/upload/${widget.productId}';
      print('Uploading to: $url'); // Debug log

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadProduct(); // Reload product to get updated image URLs
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e'); // Debug log
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final updatedProduct = await _productService.updateProduct(
          widget.productId,
          _titleController.text,
          _descriptionController.text,
        );
        setState(() {
          _product = updatedProduct;
          _isEditing = false;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(widget.productId);
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate successful deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop(false); // Return false to indicate failed deletion
        }
      }
    }
  }

  Widget _buildImageGallery() {
    if (_product == null || _product!.imageUrls.isEmpty) {
      return const Center(
        child: Text('No images available'),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _product!.imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = _product!.imageUrls[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Show full-screen image
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Product Image'),
                      ),
                      body: Center(
                        child: InteractiveViewer(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProduct,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_isEditing) ...[
                              ElevatedButton(
                                onPressed: _isLoading ? null : _updateProduct,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Save Changes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _titleController.text = _product!.title;
                                    _descriptionController.text = _product!.description;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Product Images',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_imageUrls.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  _imageUrls[index],
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 