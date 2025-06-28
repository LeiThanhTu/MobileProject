import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/screens/home/categories_screen.dart';
import 'package:test/screens/profile/profile_screen.dart';
import 'package:test/screens/results/result_screen.dart';
import 'package:test/screens/exam/exam_screen.dart';
import 'package:test/screens/quizz/quiz_screen.dart';
import 'package:test/screens/ai_chat/ai_chat_screen.dart';
import 'dart:math' as math;

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
      floatingActionButton: _AnimatedChatBubbleButton(),
    );
  }
}

class _AnimatedChatBubbleButton extends StatefulWidget {
  @override
  State<_AnimatedChatBubbleButton> createState() =>
      _AnimatedChatBubbleButtonState();
}

class _AnimatedChatBubbleButtonState extends State<_AnimatedChatBubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shakeAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatScreen()),
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.indigo, width: 2),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icon Gemini logo lắc nhẹ trái-phải
                  Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Gemini.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
