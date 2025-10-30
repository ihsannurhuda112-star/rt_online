import 'package:flutter/material.dart';
import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:rt_online/rt_online/model/login_screen.dart';

class HomeWidget extends StatefulWidget {
  final String email;
  const HomeWidget({super.key, required this.email});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  CitizenModel? citizen;

  @override
  void initState() {
    super.initState();
    _loadCitizen();
  }

  Future<void> _loadCitizen() async {
    final citizenData = await DbHelper.getCitizenByEmail(widget.email);
    if (citizenData != null) {
      setState(() {
        citizen = citizenData;
      });
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.saveLogin(false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreenDay19()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 242),
      appBar: AppBar(
        title: const Text(
          "Kontribusi saya",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 232, 233),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
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
                  const Text("Berikut kontribusi anda"),
                  SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 236, 240, 236),
                        title: "Total Paid",
                        value: "RP 200.000",
                        icon: Icons.attach_money,
                        gradientColors: [
                          Colors.greenAccent.shade400,
                          Colors.green.shade700,
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 231, 234, 236),
                        title: "Paid",
                        value: "3 Bulan",
                        icon: Icons.check_circle_outline,
                        gradientColors: [
                          Colors.blueAccent.shade400,
                          Colors.blue.shade700,
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 243, 241, 238),
                        title: "Pending",
                        value: "1 Bulan",
                        icon: Icons.schedule,
                        gradientColors: [
                          Colors.orangeAccent.shade400,
                          Colors.orange.shade700,
                        ],
                      ),
                      _buildSummaryCard(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        title: "Overdue",
                        value: "1 Bulan",
                        icon: Icons.warning_amber_rounded,
                        gradientColors: [
                          Colors.redAccent.shade400,
                          Colors.red.shade700,
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 37, 2, 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Warga',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(Icons.person, 'Name', citizen!.username),
                        _infoRow(Icons.home, 'Adress', citizen!.domisili),
                        _infoRow(Icons.email, 'Email', citizen!.email),
                        _infoRow(Icons.cake, 'Age', citizen!.age.toString()),
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
                    color: Colors.black87,
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
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
