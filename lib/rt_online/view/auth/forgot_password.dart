import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    // tutup keyboard dulu
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      Fluttertoast.showToast(
        msg:
            "Link reset kata sandi telah dikirim ke $email.\nSilakan cek inbox atau folder spam.",
      );

      // kembali ke halaman sebelumnya (biasanya login)
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal mengirim email reset.";

      if (e.code == 'user-not-found') {
        msg = "Email tidak terdaftar. Pastikan email sudah benar.";
      } else if (e.code == 'invalid-email') {
        msg = "Format email tidak valid.";
      } else if (e.code == 'network-request-failed') {
        msg = "Tidak ada koneksi internet. Coba lagi nanti.";
      } else if (e.message != null) {
        msg = e.message!;
      }

      Fluttertoast.showToast(msg: msg);
    } catch (e) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return "Email tidak boleh kosong";
    }

    // regex email sederhana
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegex.hasMatch(v)) {
      return "Format email tidak valid";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reset Kata Sandi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Masukkan email yang terdaftar. "
                  "Kami akan mengirimkan link untuk mengatur ulang kata sandi Anda.",
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: _emailValidator,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Kirim Link Reset"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
