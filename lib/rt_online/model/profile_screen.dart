import 'package:flutter/material.dart';
import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:rt_online/rt_online/model/login_screen.dart';

class ProfileSettingsWidget extends StatefulWidget {
  final String email; // Email user yang sedang login
  const ProfileSettingsWidget({super.key, required this.email});

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  CitizenModel? citizen;
  final _formKey = GlobalKey<FormState>();

  // Controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCitizen();
  }

  Future<void> _loadCitizen() async {
    final data = await DbHelper.getCitizenByEmail(widget.email);
    if (data != null) {
      setState(() {
        citizen = data;
        nameController.text = data.username;
        emailController.text = data.email;
        addressController.text = data.domisili;
        ageController.text = data.age.toString();
      });
    }
  }

  Future<void> _updateCitizen() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = CitizenModel(
      id: citizen!.id,
      username: nameController.text,
      email: emailController.text,
      password: citizen!.password, // jangan diubah
      age: int.parse(ageController.text),
      domisili: addressController.text,
    );

    await DbHelper.updateCitizen(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _logout() async {
    await PreferenceHandler.saveLogin(false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenDay19()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (citizen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile Settings"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple,
                child: Text(
                  "VL",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Full Name", nameController),
              _buildTextField("Email Address", emailController, readOnly: true),
              _buildTextField(
                "Age",
                ageController,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
              _buildTextField("Address", addressController),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Text(
                  "Version 1",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _updateCitizen,
                icon: const Icon(
                  Icons.save,
                  color: Color.fromARGB(255, 14, 13, 13),
                ),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 244, 244),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "Tidak boleh kosong";
          if (isNumeric && int.tryParse(val) == null) {
            return "Please masukan nomor yang valid";
          }
          return null;
        },
      ),
    );
  }
}
