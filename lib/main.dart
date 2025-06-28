import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'models/exam_state.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'database/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();

  try {
    // Khởi tạo database
    final dbHelper = await DatabaseHelper.instance;
    await dbHelper.database;

    // Khởi tạo các providers và services
    final userProvider = UserProvider();
    final authService = AuthService();
    final themeProvider = ThemeProvider();
    final notificationService = NotificationService();

    // Kiểm tra trạng thái onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Khởi tạo các services
    authService.initialize(userProvider);
    await userProvider.checkLoginStatus();
    await notificationService.initialize();
    await notificationService.scheduleStudyReminder();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider(
              create: (_) => ExamState(
                    questions: [],
                    userId: 0,
                    categoryId: 0,
                    totalTime: 0,
                  )),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MyApp(
          hasSeenOnboarding: hasSeenOnboarding,
          isLoggedIn: userProvider.currentUser != null,
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra khi khởi động ứng dụng',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Vui lòng thử lại sau',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initFirebase() async {
  try {
    print('Bắt đầu khởi tạo Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase đã được khởi tạo thành công!');
  } catch (e) {
    if (e
        .toString()
        .contains('A Firebase App named "[DEFAULT]" already exists')) {
      print('Firebase app đã tồn tại, bỏ qua lỗi duplicate.');
    } else {
      print('Lỗi khởi tạo Firebase: $e');
      rethrow;
    }
  }
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
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
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
      home: !hasSeenOnboarding
          ? OnboardingScreen()
          : isLoggedIn
              ? HomeScreen()
              : LoginScreen(),
    );
  }
}
