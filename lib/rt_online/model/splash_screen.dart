import 'package:flutter/material.dart';
import 'package:rt_online/buttomnavigator/buttom_navigator.dart';
import 'package:rt_online/constant/app_images.dart';
import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/model/login_screen.dart';

class SplashScreenDay19 extends StatefulWidget {
  const SplashScreenDay19({super.key});

  @override
  State<SplashScreenDay19> createState() => _SplashScreenDay19State();
}

class _SplashScreenDay19State extends State<SplashScreenDay19> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLogin = await PreferenceHandler.getLogin();
    final email = await PreferenceHandler.getEmail();

    print("Stauts login: $isLogin, Email: $email");

    if (isLogin == true && email != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ButtomNavigatorWidget(email: email),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenDay19()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(AppImages.awal2, fit: BoxFit.cover),
      ),
    );
  }
}
