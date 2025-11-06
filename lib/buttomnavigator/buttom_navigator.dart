import 'package:flutter/material.dart';
import 'package:rt_online/rt_online/model/home.dart';
import 'package:rt_online/rt_online/model/profile_screen.dart';
import 'package:rt_online/rt_online/view/payment_list.dart';

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
      HomeWidget(
        email: widget.email,
        onAddCitizenPressed: () {
          _onItemTapped(1);
        },
      ),
      PaymentListWidget(),
      ProfileSettingsWidget(email: widget.email),
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Citizens'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
