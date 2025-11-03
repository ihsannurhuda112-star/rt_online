import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/payment_model.dart';
import 'package:rt_online/rt_online/view/creat_payment.dart';
import 'package:rt_online/rt_online/view/create_citizen.dart';

class PaymentListWidget extends StatefulWidget {
  const PaymentListWidget({super.key});

  @override
  State<PaymentListWidget> createState() => _PaymentListWidgetState();
}

class _PaymentListWidgetState extends State<PaymentListWidget> {
  List<PaymentModel> payment = [];
  List<PaymentModel> filteredPayments = [];

  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final data = await DbHelper.getAllPayments();
    setState(() {
      payment = data;
      filteredPayments = data;
    });
  }

  Future<void> _deletePayment(int id) async {
    await DbHelper.deletePayment(id);
    _loadPayments();
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPayments = payment.where((p) {
        final matchesSearch =
            p.citizen.toLowerCase().contains(query) ||
            p.period.toUpperCase().contains(query);
        final matchesStatus = selectedStatus == 'All Status'
            ? true
            : p.status.toLowerCase() == selectedStatus.toLowerCase();
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Manage Contributions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatPaymentWidget()),
                );
                if (result == true) _loadPayments();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Payment"),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterPayments(),
                    decoration: InputDecoration(
                      hintText: 'Cari nama...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'All Status',
                      child: Text('All Status'),
                    ),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                      _filterPayments();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            Expanded(
              child: filteredPayments.isEmpty
                  ? const Center(child: Text("No payments found"))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Citizen')),
                          DataColumn(label: Text('Period')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredPayments.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(Text(p.citizen)),
                              DataCell(Text(p.period)),
                              DataCell(Text('Rp ${p.amount}')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.status == 'paid'
                                        ? Colors.green[100]
                                        : p.status == 'pending'
                                        ? Colors.yellow[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.status,
                                    style: TextStyle(
                                      color: p.status == 'paid'
                                          ? Colors.green[800]
                                          : p.status == 'pending'
                                          ? Colors.orange[800]
                                          : Colors.red[800],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CreatPaymentWidget(payment: p),
                                          ),
                                        );
                                        if (result == true) _loadPayments();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deletePayment(p.id!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
