import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/screens/categories_screen.dart';
import 'package:test/screens/profile_screen.dart';
import 'package:test/screens/result_screen.dart';
import 'package:test/screens/exam_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    CategoriesScreen(),
    ResultsScreen(),
    ExamScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo[600],
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Môn học'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Kết quả',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Thi thử',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
