import 'package:flutter/material.dart';
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
    isLoginFunction();
  }

  isLoginFunction() async {
    Future.delayed(Duration(seconds: 3)).then((value) async {
      var isLogin = await PreferenceHandler.getLogin();
      print(isLogin);
      if (isLogin != null && isLogin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreenDay19()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreenDay19()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Center(child: Image.asset(AppImages.rton))],
      ),
    );
  }
}
