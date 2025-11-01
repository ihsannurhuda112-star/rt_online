import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/payment_model.dart';

class CreatPaymentWidget extends StatefulWidget {
  final PaymentModel? payment;

  const CreatPaymentWidget({super.key, this.payment});

  @override
  State<CreatPaymentWidget> createState() => _CreatPaymentWidgetState();
}

class _CreatPaymentWidgetState extends State<CreatPaymentWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _citizenController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _status = 'pending';

  @override
  void initState() {
    super.initState();

    if (widget.payment != null) {
      _citizenController.text = widget.payment!.citizen;
      _periodController.text = widget.payment!.period;
      _amountController.text = widget.payment!.amount.toString();
      _status = widget.payment!.status;
    }
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final payment = PaymentModel(
        id: widget.payment?.id,
        citizen: _citizenController.text,
        period: _periodController.text,
        amount: int.parse(_amountController.text),
        status: _status,
      );

      if (widget.payment == null) {
        await DbHelper.addPayment(payment);
        // back to the list, sent "true" it can refresh data
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successfully added!')),
        );
      } else {
        await DbHelper.updatePayment(payment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successfully updated!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Add New Payment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _citizenController,
                decoration: const InputDecoration(
                  labelText: 'Citizen Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter citizen name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _periodController,
                decoration: const InputDecoration(
                  labelText: 'Period (e.g. October 2025)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter payment period'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _savePayment,
                icon: const Icon(Icons.save),
                label: const Text('Save Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
