import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/view/home/home.dart';
import 'package:rt_online/rt_online/view/home/home_firebase.dart';
import 'package:rt_online/rt_online/view/payments/payment_list_firebase.dart';
import 'package:rt_online/rt_online/view/profile/profile_screen.dart';
import 'package:rt_online/rt_online/view/payments/payment_list.dart';
import 'package:rt_online/rt_online/view/profile/profile_screen_firebase.dart';

class ButtomNavigatorWidget extends StatefulWidget {
  final String email;
  const ButtomNavigatorWidget({super.key, required this.email});

  @override
  State<ButtomNavigatorWidget> createState() => _ButtomNavigatorWidgetState();
}

class _ButtomNavigatorWidgetState extends State<ButtomNavigatorWidget> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeFirebase(
        email: widget.email,
        onNavigateToPaymentList: () {
          _onItemTapped(1);
        },
      ),
      PaymentListFirebaseWidget(),
      ProfileScreenFirebase(email: widget.email),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_sharp),
            label: 'Daftar Pembayaran',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
