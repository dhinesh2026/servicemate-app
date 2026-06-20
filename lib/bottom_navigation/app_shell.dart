import 'package:flutter/material.dart';
import 'package:servicemate_app/bookingpage/bookings_content.dart';
import 'package:servicemate_app/homepage/home_page.dart';
import 'package:servicemate_app/homepage/services_page.dart';
import 'package:servicemate_app/profilePage/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    ServicesPage(),
    BookingsContent(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),

      /// ✅ BODY
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),

      /// 🚀 MODERN MATERIAL 3 BOTTOM NAV
      bottomNavigationBar: NavigationBar(
        height: 70,
        elevation: 10,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2563EB).withOpacity(0.15),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}