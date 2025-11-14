import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rt_online/widgets/login_button.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:rt_online/rt_online/view/auth/login_screen.dart';

//Bahas Shared Preference
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "/register";
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController domController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isVisibility = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  // register() async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => HomeScreenDay15()),
  //   );
  // }

  final _formKey = GlobalKey<FormState>();
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
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  height(12),
                  Text(
                    "Daftar untuk mengakses akun Anda",
                    // style: TextStyle(fontSize: 14, color: AppColor.gray88),
                  ),
                  height(24),
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
                  buildTitle("Phone"),
                  height(12),
                  buildTextField(hintText: "Masukkan nomor telepon Anda"),

                  height(16),
                  buildTitle("age"),
                  height(12),
                  buildTextField(
                    hintText: "Masukkan usia Anda",
                    controller: ageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "age tidak boleh kosong";
                      }
                      return null;
                    },
                  ),

                  height(24),
                  LoginButtonWidget(
                    text: "Daftar",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print(emailController.text);
                        final CitizenModel data = CitizenModel(
                          email: emailController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                          age: int.parse(ageController.text),
                          domisili: domController.text,
                        );
                        DbHelper.registerUser(data);
                        Fluttertoast.showToast(msg: "Daftar Berhasil");
                        // PreferenceHandler.saveLogin(true);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreenWidget(),
                          ),
                        );
                      } else {
                        // showDialog(
                        //   context: context,
                        //   builder: (context) {
                        //     return AlertDialog(
                        //       title: Text("Validation Error"),
                        //       content: Text("Please fill all fields"),
                        //       actions: [
                        //         TextButton(
                        //           child: Text("OK"),
                        //           onPressed: () {
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //         TextButton(
                        //           child: Text("Ga OK"),
                        //           onPressed: () {
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );
                      }
                    },
                  ),
                  // height(20),
                  // LoginButton(
                  //   text: "Ke Day13",
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => DryWidgetDay13()),
                  //     );
                  //   },
                  // ),
                  height(16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun?",
                        // style: TextStyle(fontSize: 12, color: AppColor.gray88),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 20, 20, 20),
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
                  // color: AppColor.gray88,
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
        // Text(text, style: TextStyle(fontSize: 12, color: AppColor.gray88)),
      ],
    );
  }
}
