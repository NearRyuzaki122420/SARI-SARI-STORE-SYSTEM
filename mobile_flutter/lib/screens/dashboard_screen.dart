import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'inventory_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List products = [];
  List sales = [];
  List profitReport = [];
  bool isLoading = true;
  String error = '';
  String selectedFilter = 'day';

  @override
  void initState() {
    super.initState();
    fetchData();
    loadProfitReport(selectedFilter);
  }

  Future<void> fetchData() async {
    try {
      final p = await ApiService.getProducts(widget.token);
      final s = await ApiService.getSales(widget.token);

      setState(() {
        products = p;
        sales = s;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> loadProfitReport(String filter) async {
    try {
      final report = await ApiService.getProfitReport(widget.token, filter);
      setState(() {
        selectedFilter = filter;
        profitReport = report;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !AppTheme.isDarkNotifier.value;
    AppTheme.isDarkNotifier.value = newValue;
    await StorageService.saveDarkMode(newValue);
  }

  Future<void> logout() async {
    await StorageService.removeToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  double get totalProfit {
    return sales.fold(0.0, (sum, item) => sum + double.parse(item['profit'].toString()));
  }

  int get totalStocks {
    return products.fold(0, (sum, item) => sum + int.parse(item['quantity'].toString()));
  }

  Widget statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String label, String value) {
    final selected = selectedFilter == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => loadProfitReport(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? null : Colors.grey.shade400,
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: toggleDarkMode,
            icon: ValueListenableBuilder<bool>(
              valueListenable: AppTheme.isDarkNotifier,
              builder: (_, isDark, __) => Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Chip(
                          label: Text('Store Management Dashboard'),
                          backgroundColor: Colors.white24,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sari-Sari Store Overview',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track your products, monitor sold items, and view profit reports.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InventoryScreen(token: widget.token),
                                  ),
                                );
                                fetchData();
                                loadProfitReport(selectedFilter);
                              },
                              icon: const Icon(Icons.inventory_2),
                              label: const Text('Go to Inventory'),
                            ),
                            ElevatedButton.icon(
                              onPressed: logout,
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  statCard('Total Products', '${products.length}', Icons.category),
                  statCard('Available Stocks', '$totalStocks', Icons.storefront),
                  statCard('Total Profit', '₱${totalProfit.toStringAsFixed(2)}', Icons.payments),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profit Report',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              filterButton('Day', 'day'),
                              const SizedBox(width: 8),
                              filterButton('Week', 'week'),
                              const SizedBox(width: 8),
                              filterButton('Month', 'month'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (profitReport.isEmpty)
                            const Text('No report data yet.')
                          else
                            ...profitReport.map((item) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item['label'].toString()),
                                subtitle: Text(
                                  'Sales: ₱${double.parse(item['total_sales'].toString()).toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  '₱${double.parse(item['total_profit'].toString()).toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }),
                          if (error.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(error, style: const TextStyle(color: Colors.red)),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}