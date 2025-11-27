import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⬅️ TAMBAH INI
import 'package:rt_online/service/firebase_digital.dart';

import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/model/citizen_model_firebase.dart';
import 'package:rt_online/rt_online/view/auth/login_screen_firebase.dart';

class ProfileScreenFirebase extends StatefulWidget {
  final String email; // masih boleh dipakai buat tampilan kalau mau
  const ProfileScreenFirebase({super.key, required this.email});

  @override
  State<ProfileScreenFirebase> createState() => _ProfileScreenFirebaseState();
}

class _ProfileScreenFirebaseState extends State<ProfileScreenFirebase> {
  CitizenModelFirebase? citizen;
  final _formKey = GlobalKey<FormState>();

  // Controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();

  // Gambar profil (lokal, per device)
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadCitizen();
    _loadProfileImage();
  }

  ///  Ambil data warga dari Firebase berbasis UID (FirebaseAuth)
  Future<void> _loadCitizen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // kalau entah gimana user null, paksa ke login
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreenFirebase()),
          (route) => false,
        );
        return;
      }

      final data = await FirebaseDigital.getCitizenByUid(user.uid);
      if (!mounted) return;

      if (data != null) {
        setState(() {
          citizen = data;
          nameController.text = data.username;
          emailController.text = data.email;
          addressController.text = data.domisili;
          ageController.text = data.age.toString();
        });
      }
    } catch (e) {
      debugPrint('Error load citizen: $e');
    }
  }

  ///  Simpan perubahan profil ke Firebase (by UID)
  Future<void> _updateCitizen() async {
    if (!_formKey.currentState!.validate()) return;
    if (citizen == null) return;

    try {
      final updated = CitizenModelFirebase(
        uid: citizen!.uid, // ✅ pakai UID
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        age: int.parse(ageController.text.trim()),
        domisili: addressController.text.trim(),
      );

      await FirebaseDigital.updateCitizen(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
    }
  }

  ///  Logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // ✅ sign out Firebase
    } catch (_) {}
    await PreferenceHandler.saveLogin(false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenFirebase()),
      (route) => false,
    );
  }

  ///  PILIH GAMBAR dari galeri (disimpan lokal, bukan Storage)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedPath = await _saveImageLocally(File(pickedFile.path));
      await _saveProfileImagePath(
        savedPath,
      ); // simpan path ke PreferenceHandler
      setState(() {
        _profileImage = File(savedPath);
      });
    }
  }

  ///  Simpan file gambar ke folder aplikasi
  Future<String> _saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await image.copy('${directory.path}/$name.png');
    return savedImage.path;
  }

  ///  Simpan path gambar ke SharedPreferences via PreferenceHandler
  Future<void> _saveProfileImagePath(String path) async {
    await PreferenceHandler.saveProfilePhoto(path);
  }

  ///  Load gambar profil yang tersimpan
  Future<void> _loadProfileImage() async {
    final path = await PreferenceHandler.getProfilePhoto();
    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (citizen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Pengaturan Profil",
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Nama Lengkap", nameController),
              _buildTextField("Alamat Email", emailController, readOnly: true),
              _buildTextField(
                "Umur",
                ageController,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
              _buildTextField("Alamat Rumah", addressController),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Text(
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Keluar"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _updateCitizen,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Simpan Perubahan"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Widget text field dengan validator
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
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "Tidak boleh kosong";
          if (isNumeric && int.tryParse(val) == null) {
            return "Masukkan angka yang valid";
          }
          return null;
        },
      ),
    );
  }
}
