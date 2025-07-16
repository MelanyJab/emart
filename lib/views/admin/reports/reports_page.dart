// views/admin/reports/reports_page.dart
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AdminController _adminController = Get.find();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminController.getOrderStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load reports'));
        }

        final stats = snapshot.data!;
        final monthlyOrders = stats['monthlyOrders'] ?? 0;
        final totalOrders = stats['totalOrders'] ?? 0;
        final monthlyRevenue = stats['monthlyRevenue'] ?? 0.0;
        final totalRevenue = stats['totalRevenue'] ?? 0.0;

        // Sample monthly data for the chart
        final monthlyData = [
          {'month': 'Jan', 'orders': 12},
          {'month': 'Feb', 'orders': 18},
          {'month': 'Mar', 'orders': 25},
          {'month': 'Apr', 'orders': 30},
          {'month': 'May', 'orders': 28},
          {'month': 'Jun', 'orders': 35},
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Stats Cards
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('Monthly Orders', monthlyOrders.toString()),
                  _buildStatCard('Total Orders', totalOrders.toString()),
                  _buildStatCard(
                    'Monthly Revenue',
                    '\$${monthlyRevenue.toStringAsFixed(2)}',
                  ),
                  _buildStatCard(
                    'Total Revenue',
                    '\$${totalRevenue.toStringAsFixed(2)}',
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                'Monthly Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Chart
              SizedBox(
                height: 300,
                child: sf.SfCartesianChart(
                  primaryXAxis: sf.CategoryAxis(),
                  series: <sf.CartesianSeries<Map<String, dynamic>, String>>[
                    sf.ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: monthlyData,
                      xValueMapper: (data, _) => data['month'],
                      yValueMapper: (data, _) => data['orders'],
                      color: Colors.red,
                      dataLabelSettings:
                          const sf.DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
