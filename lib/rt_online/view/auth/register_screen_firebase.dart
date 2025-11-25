import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rt_online/rt_online/view/auth/login_screen_firebase.dart';
import 'package:rt_online/service/firebase_digital.dart';
import 'package:rt_online/widgets/login_button.dart';
import 'package:rt_online/rt_online/model/citizen_model_firebase.dart';

class RegisterScreenFirebase extends StatefulWidget {
  const RegisterScreenFirebase({super.key});
  static const id = "/register_firebase";

  @override
  State<RegisterScreenFirebase> createState() => _RegisterScreenFirebaseState();
}

class _RegisterScreenFirebaseState extends State<RegisterScreenFirebase> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController domController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    domController.dispose();
    ageController.dispose();
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
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  height(12),
                  const Text("Daftar untuk mengakses akun Anda"),
                  height(24),

                  // Username
                  buildTitle("Username"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan nama pengguna Anda",
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username tidak boleh kosong";
                      }
                      return null;
                    },
                  ),

                  height(16),
                  // Email
                  buildTitle("Email Address"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan email Anda",
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
                  // Password
                  buildTitle("Password"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan kata sandi Anda",
                    isPassword: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password tidak boleh kosong";
                      } else if (value.length < 6) {
                        return "Password minimal 6 karakter";
                      }
                      return null;
                    },
                  ),

                  height(16),
                  // Domisili
                  buildTitle("Domisili"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan alamat Anda",
                    controller: domController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Domisili tidak boleh kosong";
                      }
                      return null;
                    },
                  ),

                  height(16),
                  // Phone (belum ke model)
                  buildTitle("Phone"),
                  height(12),
                  buildTextField(hintText: "Masukkan nomor telepon Anda"),

                  height(16),
                  // Age
                  buildTitle("Age"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan usia Anda",
                    controller: ageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "age tidak boleh kosong";
                      }
                      if (int.tryParse(value) == null) {
                        return "age harus berupa angka";
                      }
                      return null;
                    },
                  ),

                  height(24),

                  /// 🔥 REGISTER via Firebase Auth + simpan profil ke Firestore
                  LoginButtonWidget(
                    text: "Daftar",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // 1. Buat akun di Firebase Auth
                          final cred = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                          final uid = cred.user!.uid;

                          // 2. Simpan data profil ke Firestore (tanpa password)
                          final citizen = CitizenModelFirebase(
                            uid: uid, // ⬅️ gunakan uid di model
                            email: emailController.text.trim(),
                            username: usernameController.text.trim(),
                            age: int.parse(ageController.text.trim()),
                            domisili: domController.text.trim(),
                          );

                          await FirebaseDigital.createCitizen(citizen);

                          Fluttertoast.showToast(msg: "Daftar Berhasil");

                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreenFirebase(),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                            msg: e.message ?? "Terjadi kesalahan saat daftar",
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Terjadi kesalahan: $e");
                        }
                      }
                    },
                  ),

                  height(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Masuk",
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
          image: AssetImage("assets/images/rtregister.png"),
          fit: BoxFit.cover,
          opacity: 3,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 15, 15, 15).withOpacity(0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 20, 20, 20),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 14, 13, 13).withOpacity(0.2),
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
