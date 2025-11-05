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
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Manage Contributions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatPaymentWidget(),
                    ),
                  );
                  if (result == true) _loadPayments();
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Payment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              onChanged: (value) => _filterPayments(),
              decoration: InputDecoration(
                hintText: 'Cari nama atau periode...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: DropdownButton<String>(
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
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredPayments.isEmpty
                  ? const Center(child: Text("No payments found"))
                  : ListView.builder(
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final p = filteredPayments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.citizen,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Period: ${p.period}"),
                                    Text("Jumlah: Rp ${p.amount}"),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.status == 'paid'
                                            ? Colors.green.shade100
                                            : p.status == 'pending'
                                            ? Colors.yellow.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.status,
                                        style: TextStyle(
                                          color: p.status == 'paid'
                                              ? Colors.green.shade800
                                              : p.status == 'pending'
                                              ? Colors.orange.shade800
                                              : Colors.red.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                                    CreatPaymentWidget(
                                                      payment: p,
                                                    ),
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
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Konfirmasi Hapus',
                                                ),
                                                content: const Text(
                                                  'Apakah Anda yakin ingin menghapus data ini?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Batal'),
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text('Hapus'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await _deletePayment(p.id!);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Data berhasil dihapus',
                                                  ),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                        255,
                                                        19,
                                                        18,
                                                        18,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
