// views/admin/orders/orders_table.dart
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersTable extends StatefulWidget {
  const OrdersTable({Key? key}) : super(key: key);

  @override
  State<OrdersTable> createState() => _OrdersTableState();
}

class _OrdersTableState extends State<OrdersTable> {
  final AdminController _adminController = Get.find();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _adminController.getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        final orders = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Items')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: orders.map((order) {
              return DataRow(cells: [
                DataCell(Text(order.id.substring(0, 8))),
                DataCell(Text(order.userEmail)),
                DataCell(Text('${order.items.length} items')),
                DataCell(Text('\$${order.totalAmount.toStringAsFixed(2)}')),
                DataCell(
                  Chip(
                    label: Text(
                      order.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                ),
                DataCell(Text(_formatDate(order.createdAt))),
                DataCell(
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'update',
                        child: Text('Update Status'),
                      ),
                    ],
                    onSelected: (value) => _handleOrderAction(value, order),
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleOrderAction(String action, OrderModel order) {
    if (action == 'view') {
      _showOrderDetails(order);
    } else if (action == 'update') {
      _updateOrderStatus(order);
    }
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${order.userEmail}'),
              Text('Date: ${_formatDate(order.createdAt)}'),
              Text('Status: ${order.status}'),
              Text('Payment: ${order.paymentMethod ?? 'N/A'}'),
              Text('Shipping: ${order.shippingAddress ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => ListTile(
                leading: Image.network(item.imageUrl, width: 40, height: 40),
                title: Text(item.name),
                subtitle: Text('\$${item.totalPrice.toStringAsFixed(2)} x ${item.quantity}'),
              )),
              const SizedBox(height: 16),
              Text('Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

 void _updateOrderStatus(OrderModel order) {
  final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  String? newStatus = order.status;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: DropdownButtonFormField<String>(
            value: newStatus,
            items: statuses.map<DropdownMenuItem<String>>((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status[0].toUpperCase() + status.substring(1)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                newStatus = value;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select Status',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newStatus != null && newStatus != order.status) {
                  try {
                    await _adminController.firestore
                        .collection('orders')
                        .doc(order.id)
                        .update({'status': newStatus});
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {
                        order.status = newStatus!;
                      });
                      Get.snackbar('Success', 'Order status updated');
                    }
                  } catch (e) {
                    if (mounted) {
                      Get.snackbar('Error', 'Failed to update status');
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    ),
  );
}
}