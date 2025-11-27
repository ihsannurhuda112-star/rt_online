import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 TAMBAH INI
import 'package:rt_online/rt_online/model/payment_model_firebase.dart';
import 'package:rt_online/rt_online/view/payments/create_payment_firebase.dart';
import 'package:rt_online/service/firebase_digital.dart';

class PaymentListFirebaseWidget extends StatefulWidget {
  const PaymentListFirebaseWidget({super.key});

  @override
  State<PaymentListFirebaseWidget> createState() =>
      _PaymentListFirebaseWidgetState();
}

class _PaymentListFirebaseWidgetState extends State<PaymentListFirebaseWidget> {
  List<PaymentModelFirebase> payments = [];
  List<PaymentModelFirebase> filteredPayments = [];

  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    //  Ambil user yang lagi login
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // optional: bisa lempar ke login kalau mau
      return;
    }

    //  Ambil payment hanya milik UID ini
    final data = await FirebaseDigital.getPaymentsByOwnerUid(user.uid);

    setState(() {
      payments = data;
      filteredPayments = data;
    });
  }

  Future<void> _deletePayment(String id) async {
    await FirebaseDigital.deletePayment(id);
    await _loadPayments();
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPayments = payments.where((p) {
        final matchesSearch =
            p.citizen.toLowerCase().contains(query) ||
            p.period.toLowerCase().contains(query);
        final matchesStatus = selectedStatus == 'All Status'
            ? true
            : p.status.toLowerCase() == selectedStatus.toLowerCase();
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Kelola Kontribusi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // tombol tambah pembayaran
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatePaymentFirebaseWidget(),
                    ),
                  );
                  if (result == true) _loadPayments();
                },
                icon: const Icon(Icons.add),
                label: const Text("Tambahkan Pembayaran"),
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

            // search
            TextField(
              controller: _searchController,
              onChanged: (_) => _filterPayments(),
              decoration: InputDecoration(
                hintText: 'Cari nama / periode...',
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
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: selectedStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'All Status',
                    child: Text('Semua Status'),
                  ),
                  DropdownMenuItem(value: 'paid', child: Text('Dibayar')),
                  DropdownMenuItem(value: 'pending', child: Text('Tertunda')),
                  DropdownMenuItem(value: 'overdue', child: Text('Terlambat')),
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
                  ? const Center(child: Text("Pembayaran tidak ditemukan"))
                  : ListView.builder(
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final p = filteredPayments[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // info kiri
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
                                    Text("Periode: ${p.period}"),
                                    Text("Jumlah: Rp ${p.amount}"),
                                  ],
                                ),

                                // status + aksi kanan
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
                                        // edit
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
                                                    CreatePaymentFirebaseWidget(
                                                      payment: p,
                                                    ),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadPayments();
                                            }
                                          },
                                        ),
                                        // delete
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
                                                          foregroundColor:
                                                              Colors.white,
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

                                            if (confirm == true &&
                                                p.id != null) {
                                              await _deletePayment(p.id!);
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Data berhasil dihapus',
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
