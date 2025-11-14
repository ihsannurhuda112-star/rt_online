import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/payment_model.dart';

class CreatePaymentWidget extends StatefulWidget {
  final PaymentModel? payment;

  const CreatePaymentWidget({super.key, this.payment});

  @override
  State<CreatePaymentWidget> createState() => _CreatePaymentWidgetState();
}

class _CreatePaymentWidgetState extends State<CreatePaymentWidget> {
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
          const SnackBar(content: Text('Pembayaran berhasil ditambahkan!')),
        );
      } else {
        await DbHelper.updatePayment(payment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tambahkan Pembayaran Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                  labelText: 'Nama Warga',
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
                  labelText: 'Periode (Contoh Oktober 2025)',
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
                  labelText: 'Jumlah (Rp)',
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
                  DropdownMenuItem(value: 'paid', child: Text('Dibayar')),
                  DropdownMenuItem(value: 'pending', child: Text('Tertunda')),
                  DropdownMenuItem(value: 'overdue', child: Text('Terlambat')),
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
                label: const Text('Simpan Pembayaran'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
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
