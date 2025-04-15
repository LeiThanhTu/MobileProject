import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'models/exam_state.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Khởi tạo database trước
    final dbHelper = await DatabaseHelper.instance;
    await dbHelper.database; // Đảm bảo database đã được khởi tạo

    // Khởi tạo các providers và services
    final userProvider = UserProvider();
    final authService = AuthService();
    final themeProvider = ThemeProvider();
    final notificationService = NotificationService();

    // Kiểm tra trạng thái onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Khởi tạo các services theo thứ tự
    authService.initialize(userProvider);
    await userProvider.checkLoginStatus();
    await notificationService.initialize();

    // Lên lịch thông báo nhắc nhở học tập
    await notificationService.scheduleStudyReminder();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider(
            create: (_) => ExamState(
              questions: [],
              userId: 0,
              categoryId: 0,
              totalTime: 0,
            ),
          ),
          ChangeNotifierProvider(create: (_) => themeProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MyApp(
          hasSeenOnboarding: hasSeenOnboarding,
          isLoggedIn: userProvider.currentUser != null,
        ),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    // Hiển thị một màn hình lỗi thân thiện với người dùng
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child:
                Text('Có lỗi xảy ra khi khởi động ứng dụng. Vui lòng thử lại.'),
          ),
        ),
      ),
    );
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
        },
      ),
    );
  }
}

// ... existing code ...
