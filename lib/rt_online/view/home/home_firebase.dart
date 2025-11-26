import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // buat ambil currentUser
import 'package:rt_online/rt_online/model/citizen_model_firebase.dart';
import 'package:rt_online/rt_online/view/payments/payment_list.dart';
import 'package:rt_online/service/firebase_digital.dart';
import 'package:rt_online/preferences/preference_handler.dart';

class HomeFirebase extends StatefulWidget {
  final String email;
  final VoidCallback? onNavigateToPaymentList;

  const HomeFirebase({
    super.key,
    required this.email,
    this.onNavigateToPaymentList,
  });

  @override
  State<HomeFirebase> createState() => _HomeFirebaseState();
}

class _HomeFirebaseState extends State<HomeFirebase> {
  CitizenModelFirebase? citizen;
  int totalCitizens = 0;
  int totalCollected = 0;
  int totalPaid = 0;
  int overdue = 0;

  File? _profileImage; // foto profil di home

  @override
  void initState() {
    super.initState();
    _loadCitizen();
    _loadSummaryData();
    _loadProfileImage();
  }

  /// 🔹 Ambil data warga dari Firestore berdasarkan UID
  Future<void> _loadCitizen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final citizenData = await FirebaseDigital.getCitizenByUid(user.uid);
      if (!mounted) return;

      if (citizenData != null) {
        setState(() {
          citizen = citizenData;
        });
      }
    } catch (e) {
      debugPrint('Error load citizen: $e');
    }
  }

  /// 🔹 Ambil summary pembayaran PER AKUN (pakai ownerUid)
  Future<void> _loadSummaryData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ambil semua pembayaran milik user ini (ownerUid)
      final payments = await FirebaseDigital.getPaymentsByOwnerUid(user.uid);

      if (!mounted) return;

      setState(() {
        // 🔥 hitung jumlah warga unik dari field `citizen`
        final uniqueCitizens = payments
            .map(
              (p) => p.citizen.trim().toLowerCase(),
            ) // biar "Admin" & "admin" dianggap sama
            .toSet();

        totalCitizens = uniqueCitizens.length;

        totalPaid = payments.where((e) => e.status == "paid").length;
        overdue = payments.where((e) => e.status == "overdue").length;

        totalCollected = payments
            .where((p) => p.status == "paid")
            .fold(0, (sum, p) => sum + p.amount);
      });
    } catch (e) {
      debugPrint('Error load summary: $e');
    }
  }

  /// 🔹 Ambil path foto profil dari PreferenceHandler
  Future<void> _loadProfileImage() async {
    final path = await PreferenceHandler.getProfilePhoto();
    if (path != null && mounted) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _navigateToPaymentList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentListWidget()),
    );
    _loadSummaryData(); // refresh setelah balik dari list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
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
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header user
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.deepPurple.shade100,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                citizen!.username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Berikut ini adalah kontribusi dari warga",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // summary cards
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildSummaryCard(
                          color: Colors.green,
                          title: "Total Pembayaran",
                          value: "Rp $totalCollected",
                          icon: Icons.attach_money,
                          gradientColors: [
                            Colors.greenAccent.shade400,
                            Colors.green.shade700,
                          ],
                        ),
                        _buildSummaryCard(
                          color: Colors.blue,
                          title: "Pembayaran Selesai",
                          value: "$totalPaid pembayaran",
                          icon: Icons.check_circle_outline,
                          gradientColors: [
                            Colors.blueAccent.shade400,
                            Colors.blue.shade700,
                          ],
                        ),
                        _buildSummaryCard(
                          color: const Color(0xFF7E1CFF),
                          title: "Total Warga",
                          value: "$totalCitizens warga",
                          icon: Icons.people,
                          gradientColors: const [
                            Color.fromARGB(255, 126, 28, 255),
                            Color.fromARGB(255, 110, 18, 231),
                          ],
                        ),
                        _buildSummaryCard(
                          color: Colors.red,
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

                    const SizedBox(height: 24),

                    // aksi cepat
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Aksi Cepat",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    widget.onNavigateToPaymentList ??
                                    _navigateToPaymentList,
                                icon: const Icon(Icons.payment_rounded),
                                label: const Text("Lihat Pembayaran"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // info kepala RT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 12),
                          _infoRow(Icons.person, 'Nama', citizen!.username),
                          _infoRow(
                            Icons.home,
                            'Alamat Rumah',
                            citizen!.domisili,
                          ),
                          _infoRow(Icons.email, 'Email', citizen!.email),
                          _infoRow(Icons.cake, 'Umur', citizen!.age.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
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
    final double cardWidth =
        (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return SizedBox(
      width: cardWidth,
      child: Container(
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
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
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
