import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rt_online/navigation/buttom_navigator.dart';
import 'package:rt_online/rt_online/view/auth/register_screen_firebase.dart';
import 'package:rt_online/service/firebase_digital.dart';
import 'package:rt_online/widgets/login_button.dart';
import 'package:rt_online/preferences/preference_handler.dart';

class LoginScreenFirebase extends StatefulWidget {
  const LoginScreenFirebase({super.key});
  static const id = "/login_screen19";

  @override
  State<LoginScreenFirebase> createState() => _LoginScreenFirebaseState();
}

class _LoginScreenFirebaseState extends State<LoginScreenFirebase> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  SafeArea buildLayer() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  height(12),
                  const Text("Masuk untuk mengakses akun Anda"),
                  height(24),

                  // EMAIL
                  buildTitle("Email Address"),
                  height(12),
                  buildTextField(
                    hintText: "Masukan alamat email",
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email tidak boleh kosong";
                      } else if (!value.contains('@')) {
                        return "Email tidak valid";
                      } else if (!RegExp(
                        r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
                      ).hasMatch(value)) {
                        return "Format Email tidak valid";
                      }
                      return null;
                    },
                  ),

                  height(16),

                  // PASSWORD
                  buildTitle("Password"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan kata sandi Anda",
                    isPassword: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password tidak boleh kosong";
                      }
                      if (value.length < 6) {
                        return "Password minimal 6 karakter";
                      }
                      return null;
                    },
                  ),

                  height(12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Nanti bisa diisi:
                        // FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                      },
                      child: const Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  height(24),

                  // 🔥 LOGIN – Firebase Auth + (opsional) ambil profil dari Firestore
                  LoginButtonWidget(
                    text: "Masuk",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // 1. Login ke Firebase Auth
                          final cred = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                          final user = cred.user;
                          if (user == null) {
                            Fluttertoast.showToast(
                              msg: "Login gagal: user tidak ditemukan",
                            );
                            return;
                          }

                          final email =
                              user.email ?? emailController.text.trim();
                          final uid = user.uid;

                          // 2. (Opsional) Ambil profil dari Firestore kalau mau dipakai
                          // final citizen =
                          //     await FirebaseDigital.getCitizenByEmail(email);

                          // 3. Simpan session ke SharedPreferences
                          await PreferenceHandler.saveLogin(true);
                          await PreferenceHandler.saveEmail(email);
                          // Kalau kamu sudah tambahin saveUid di PreferenceHandler:
                          // await PreferenceHandler.saveUid(uid);

                          if (!mounted) return;

                          // 4. Arahkan ke home / bottom navigator
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ButtomNavigatorWidget(email: email),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String msg = "Terjadi kesalahan saat login";
                          if (e.code == 'user-not-found') {
                            msg = "Pengguna tidak ditemukan";
                          } else if (e.code == 'wrong-password') {
                            msg = "Password salah";
                          } else if (e.message != null) {
                            msg = e.message!;
                          }
                          Fluttertoast.showToast(msg: msg);
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Terjadi kesalahan: $e");
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Kesalahan Validasi"),
                              content: const Text("Silakan isi semua kolom"),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),

                  height(16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreenFirebase(),
                            ),
                          );
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/newlg2.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  TextFormField buildTextField({
    String? hintText,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: isPassword ? !isVisibility : false,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isVisibility = !isVisibility;
                  });
                },
                icon: Icon(
                  isVisibility ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }

  SizedBox height(double height) => SizedBox(height: height);
  SizedBox width(double width) => SizedBox(width: width);

  Widget buildTitle(String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
