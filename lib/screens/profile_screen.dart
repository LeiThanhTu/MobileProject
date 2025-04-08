import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/providers/theme_provider.dart';
import 'package:test/screens/login_screen.dart';
import 'package:test/screens/onboarding_screen.dart';
import 'package:test/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.indigo[100],
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildProfileItem(
                      context,
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      'Theme Mode',
                      () {},
                      isThemeMode: true,
                    ),
                    _buildProfileItem(context, Icons.settings, 'Settings', () {
                      if (user?.email != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SettingsScreen(email: user!.email),
                          ),
                        );
                      }
                    }),
                    _buildProfileItem(
                      context,
                      Icons.help_outline,
                      'Help & Support',
                      () {
                        // Navigate to help
                      },
                    ),
                    _buildProfileItem(context, Icons.info_outline, 'About', () {
                      // Show about dialog
                      showAboutDialog(
                        context: context,
                        applicationName: 'QuizMaster',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 QuizMaster',
                        children: [
                          SizedBox(height: 16),
                          Text('A Flutter Quiz App with SQLite database.'),
                        ],
                      );
                    }),
                    _buildProfileItem(
                      context,
                      Icons.refresh,
                      'Xem lại giới thiệu',
                      () => _resetOnboarding(context),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          await userProvider.logout();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isThemeMode = false,
  }) {
    return Card(
      elevation: 0,
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.indigo[200]
                  : Colors.indigo[600],
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        trailing:
            isThemeMode
                ? Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: Colors.indigo,
                      activeTrackColor: Colors.indigo[200],
                    );
                  },
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey,
                ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: isThemeMode ? null : onTap,
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenOnboarding');

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
      (route) => false,
    );
  }
}
