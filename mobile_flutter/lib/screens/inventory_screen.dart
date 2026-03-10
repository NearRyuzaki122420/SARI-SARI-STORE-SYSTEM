import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  final String token;
  const InventoryScreen({super.key, required this.token});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List products = [];
  bool isLoading = true;
  String message = '';
  String error = '';

  final addCodeController = TextEditingController();
  final addNameController = TextEditingController();
  final addTypeController = TextEditingController();
  final addQtyController = TextEditingController(text: '1');
  final addCostController = TextEditingController(text: '0');
  final addSellController = TextEditingController(text: '0');

  int? restockProductId;
  final restockQtyController = TextEditingController(text: '1');
  final restockCostController = TextEditingController();
  final restockSellController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final result = await ApiService.getProducts(widget.token);
      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !AppTheme.isDarkNotifier.value;
    AppTheme.isDarkNotifier.value = newValue;
    await StorageService.saveDarkMode(newValue);
  }

  Future<void> addProduct() async {
    setState(() {
      message = '';
      error = '';
    });

    try {
      final res = await ApiService.addProduct(widget.token, {
        'product_code': addCodeController.text.trim(),
        'product_name': addNameController.text.trim(),
        'product_type': addTypeController.text.trim(),
        'quantity': int.parse(addQtyController.text),
        'cost_price': double.parse(addCostController.text),
        'selling_price': double.parse(addSellController.text),
      });

      setState(() => message = res['message']);
      addCodeController.clear();
      addNameController.clear();
      addTypeController.clear();
      addQtyController.text = '1';
      addCostController.text = '0';
      addSellController.text = '0';
      fetchProducts();
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> restockProduct() async {
    if (restockProductId == null) {
      setState(() => error = 'Please select a product to restock');
      return;
    }

    setState(() {
      message = '';
      error = '';
    });

    try {
      final payload = <String, dynamic>{
        'quantity': int.parse(restockQtyController.text),
      };

      if (restockCostController.text.trim().isNotEmpty) {
        payload['cost_price'] = double.parse(restockCostController.text);
      }

      if (restockSellController.text.trim().isNotEmpty) {
        payload['selling_price'] = double.parse(restockSellController.text);
      }

      final res = await ApiService.restockProduct(widget.token, restockProductId!, payload);
      setState(() => message = res['message']);

      restockProductId = null;
      restockQtyController.text = '1';
      restockCostController.clear();
      restockSellController.clear();
      fetchProducts();
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> sellProduct(int id) async {
    final controller = TextEditingController(text: '1');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sell Product'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity Sold'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sold')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final res = await ApiService.sellProduct(
        widget.token,
        id,
        int.parse(controller.text),
      );
      setState(() {
        message = res['message'];
        error = '';
      });
      fetchProducts();
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteProduct(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final res = await ApiService.deleteProduct(widget.token, id);
      setState(() {
        message = res['message'];
        error = '';
      });
      fetchProducts();
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget field(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Color statusColor(String status) {
    return status == 'Sold' ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: toggleDarkMode,
            icon: ValueListenableBuilder<bool>(
              valueListenable: AppTheme.isDarkNotifier,
              builder: (_, isDark, __) => Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchProducts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text('Inventory Management'),
                          backgroundColor: Colors.white24,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Store Inventory',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add new items, restock products, mark sold items, or delete phased-out products.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add Product',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          field('Product Code', addCodeController),
                          field('Product Name', addNameController),
                          field('Product Type', addTypeController),
                          field('Quantity', addQtyController, keyboardType: TextInputType.number),
                          field('Cost Price', addCostController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          field('Selling Price', addSellController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: addProduct,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Add Product'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Restock Product',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: restockProductId,
                            items: products.map<DropdownMenuItem<int>>((product) {
                              return DropdownMenuItem<int>(
                                value: product['id'] as int,
                                child: Text('${product['product_name']} - ${product['product_type']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => restockProductId = value);
                            },
                            decoration: const InputDecoration(labelText: 'Select Product'),
                          ),
                          const SizedBox(height: 12),
                          field('Restock Quantity', restockQtyController, keyboardType: TextInputType.number),
                          field('Updated Cost Price (optional)', restockCostController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          field('Updated Selling Price (optional)', restockSellController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: restockProduct,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Restock Product'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(message, style: const TextStyle(color: Colors.green)),
                  ],
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(error, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Inventory List',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...products.map((product) {
                    final status = product['status'].toString();
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['product_name'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text('Code: ${product['product_code']}'),
                            Text('Type: ${product['product_type']}'),
                            Text('Quantity: ${product['quantity']}'),
                            Text('Cost Price: ₱${double.parse(product['cost_price'].toString()).toStringAsFixed(2)}'),
                            Text('Selling Price: ₱${double.parse(product['selling_price'].toString()).toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(status),
                              backgroundColor: statusColor(status).withOpacity(0.15),
                              labelStyle: TextStyle(color: statusColor(status)),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: int.parse(product['quantity'].toString()) <= 0
                                      ? null
                                      : () => sellProduct(product['id'] as int),
                                  icon: const Icon(Icons.shopping_cart_checkout),
                                  label: const Text('Sold'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => deleteProduct(product['id'] as int),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}