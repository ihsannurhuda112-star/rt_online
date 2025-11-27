import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⬅️ TAMBAH INI
import 'package:rt_online/rt_online/model/payment_model_firebase.dart';
import 'package:rt_online/service/firebase_digital.dart';

class CreatePaymentFirebaseWidget extends StatefulWidget {
  final PaymentModelFirebase? payment;

  const CreatePaymentFirebaseWidget({super.key, this.payment});

  @override
  State<CreatePaymentFirebaseWidget> createState() =>
      _CreatePaymentFirebaseWidgetState();
}

class _CreatePaymentFirebaseWidgetState
    extends State<CreatePaymentFirebaseWidget> {
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
      try {
        //  Ambil UID user yang sedang login
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User tidak login. Silakan login ulang.'),
            ),
          );
          return;
        }

        //  Kalau edit, pakai ownerUid yang lama. Kalau create baru, pakai user.uid
        final payment = PaymentModelFirebase(
          id: widget.payment?.id, // null = create baru, isi = edit
          ownerUid: widget.payment?.ownerUid ?? user.uid,
          citizen: _citizenController.text.trim(),
          period: _periodController.text.trim(),
          amount: int.parse(_amountController.text.trim()),
          status: _status,
        );

        if (widget.payment == null) {
          // CREATE ke Firestore
          await FirebaseDigital.addPayment(payment);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil ditambahkan!')),
          );
          Navigator.pop(context, true);
        } else {
          // UPDATE ke Firestore
          await FirebaseDigital.updatePayment(payment);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil diperbarui!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  void dispose() {
    _citizenController.dispose();
    _periodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.payment != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEdit ? 'Edit Pembayaran' : 'Tambahkan Pembayaran Baru',
          style: const TextStyle(
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
                  labelText: 'Nama Warga / Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan nama warga'
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
                    ? 'Masukkan periode pembayaran'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah harus angka';
                  }
                  return null;
                },
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
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _savePayment,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update Pembayaran' : 'Simpan Pembayaran'),
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
