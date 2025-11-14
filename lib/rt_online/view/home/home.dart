import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:rt_online/rt_online/view/payments/payment_list.dart';

class HomeWidget extends StatefulWidget {
  final String email;
  final VoidCallback? onNavigateToPaymentList;
  const HomeWidget({
    super.key,
    required this.email,
    this.onNavigateToPaymentList,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  CitizenModel? citizen;
  int totalCitizens = 0;
  int totalCollected = 0;
  int totalPaid = 0;
  int overdue = 0;

  @override
  void initState() {
    super.initState();
    _loadCitizen();
    _loadSummaryData();
  }

  // data dari email
  Future<void> _loadCitizen() async {
    final citizenData = await DbHelper.getCitizenByEmail(widget.email);
    if (citizenData != null) {
      setState(() {
        citizen = citizenData;
      });
    }
  }

  //ambil semua data summary from database
  Future<void> _loadSummaryData() async {
    final payments = await DbHelper.getAllPayments();
    setState(() {
      totalCitizens = payments.length;
      totalPaid = payments.where((e) => e.status == "paid").length;
      overdue = payments.where((e) => e.status == "overdue").length;
      totalCollected = payments
          .where((p) => p.status == "paid")
          .fold(0, (sum, p) => sum + p.amount);
    });
  }

  //navigasi ke halaman + warga dan refresh dashbord setelah kembali
  Future<void> _navigateToPaymentList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentListWidget()),
    );
    _loadSummaryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: citizen == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    citizen!.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  const Text("Berikut ini adalah kontribusi dari warga"),
                  SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 236, 240, 236),
                        title: "Total Pembayaran",
                        value: "RP $totalCollected",
                        icon: Icons.attach_money,
                        gradientColors: [
                          Colors.greenAccent.shade400,
                          Colors.green.shade700,
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 231, 234, 236),
                        title: "Total Pembayaran",
                        value: "$totalPaid pembayaran",
                        icon: Icons.check_circle_outline,
                        gradientColors: [
                          Colors.blueAccent.shade400,
                          Colors.blue.shade700,
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 243, 241, 238),
                        title: "Total Warga",
                        value: "$totalCitizens warga",
                        icon: Icons.people,
                        gradientColors: [
                          const Color.fromARGB(255, 126, 28, 255),
                          const Color.fromARGB(255, 110, 18, 231),
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        title: "Keterlambatan",
                        value: "$overdue terlambat",
                        icon: Icons.warning_amber_rounded,
                        gradientColors: [
                          Colors.redAccent.shade400,
                          Colors.red.shade700,
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                    margin: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Aksi Cepat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  widget.onNavigateToPaymentList ??
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Aksi belum diatur'),
                                      ),
                                    );
                                  },
                              icon: const Icon(Icons.payment_rounded),
                              label: const Text("Lihat Pembayaran"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    10,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 37, 2, 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Kepala RT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(Icons.person, 'Nama', citizen!.username),
                        _infoRow(Icons.home, 'Alamat Rumah', citizen!.domisili),
                        _infoRow(Icons.email, 'Email', citizen!.email),
                        _infoRow(Icons.cake, 'Umur', citizen!.age.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required Color color,
    required String title,
    required String value,
    required IconData icon,
    List<Color>? gradientColors,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [color.withOpacity(0.7), color],
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
