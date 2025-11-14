import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rt_online/navigation/buttom_navigator.dart';
import 'package:rt_online/widgets/login_button.dart';
import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/view/auth/register_screen.dart';

//Bahas Shared Preference
class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});
  static const id = "/login_screen19";
  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isVisibility = false;
  bool isbuttonenable = false;
  bool obsucrepass = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  void checkformField() {
    setState(() {
      isbuttonenable =
          emailController.text.isNotEmpty &&
          usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  final _formKey = GlobalKey<FormState>();
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
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  height(12),
                  Text(
                    "Masuk untuk mengakses akun Anda",
                    // style: TextStyle(fontSize: 14, color: AppColor.gray88),
                  ),
                  height(24),
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
                  height(12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => HomeScreen()),
                        // );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => MeetSebelas()),
                        // );
                      },
                      child: Text(
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
                  LoginButtonWidget(
                    text: "Masuk",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print(emailController.text);
                        PreferenceHandler.saveLogin(true);
                        final data = await DbHelper.loginUser(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        if (data != null) {
                          await PreferenceHandler.saveLogin(true);
                          await PreferenceHandler.saveEmail(data.email);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ButtomNavigatorWidget(
                                email: data.email,
                                //email: emailController.text,
                                //name: usernameController.text,
                                //age: "",
                              ),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Email atau password salah",
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Kesalahan Validasi"),
                              content: Text("Silakan isi semua kolom"),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text("Belum punya akun? Daftar"),
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
                  // height(16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Expanded(
                  //       child: Container(
                  //         margin: EdgeInsets.only(right: 8),
                  //         height: 1,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //     Text(
                  //       "Or Sign In With",
                  //       // style: TextStyle(fontSize: 12, color: AppColor.gray88),
                  //     ),
                  //     Expanded(
                  //       child: Container(
                  //         margin: EdgeInsets.only(left: 8),

                  //         height: 1,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // height(16),
                  // SizedBox(
                  //   height: 48,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       // Navigate to MeetLima screen menggunakan pushnamed
                  //       Navigator.pushNamed(context, "/meet_2");
                  //     },
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           "assets/images/goggle.png",
                  //           height: 16,
                  //           width: 16,
                  //         ),
                  //         width(4),
                  //         Text("Google"),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  height(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun?",
                        // style: TextStyle(fontSize: 12, color: AppColor.gray88),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                          // context.push(RegisterScreen());
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => MeetEmpatA()),
                          // );
                        },
                        child: Text(
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
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
