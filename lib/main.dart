import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'models/exam_state.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các providers và services
  final userProvider = UserProvider();
  final authService = AuthService();
  final themeProvider = ThemeProvider();

  // Kiểm tra trạng thái onboarding
  final prefs = await SharedPreferences.getInstance();


  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Khởi tạo auth service sau khi đã kiểm tra onboarding
  authService.initialize(userProvider);
  await userProvider.checkLoginStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(
          create:
              (_) => ExamState(
                questions: [],
                userId: 0,
                categoryId: 0,
                totalTime: 0,
              ),
        ),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: MyApp(
        hasSeenOnboarding: hasSeenOnboarding,
        isLoggedIn: userProvider.currentUser != null,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    Key? key,
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Ứng dụng thi trắc nghiệm',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.indigo[800]),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.indigo[200]),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:
          !hasSeenOnboarding
              ? OnboardingScreen()
              : isLoggedIn
              ? HomeScreen()
              : LoginScreen(),
    );
  }
}

// ... existing code ...
