import 'package:flutter/material.dart';
import 'package:rt_online/navigation/buttom_navigator.dart';
import 'package:rt_online/constant/app_images.dart';
import 'package:rt_online/preferences/preference_handler.dart';
import 'package:rt_online/rt_online/view/auth/login_screen.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
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
        MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
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
        child: Image.asset(AppImages.rtnew1, fit: BoxFit.cover),
      ),
    );
  }
}
