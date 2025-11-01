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

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final data = await DbHelper.getAllPayments();
    setState(() {
      payment = data;
    });
  }

  Future<void> _deletePayment(int id) async {
    await DbHelper.deletePayment(id);
    _loadPayments();
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
            Expanded(
              child: ListView.builder(
                itemCount: payment.length,
                itemBuilder: (context, index) {
                  final p = payment[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        "${p.citizen} (${p.period} (${p.amount}) (${p.status}))",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePayment(p.id!),
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
