import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicemate_app/ServicePage/ScheduledWaitingPage.dart';
import 'package:servicemate_app/bottom_navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './onboardingPage/onboarding_screen.dart';
import './loginPage/signupPage.dart';
import './loginPage/loginPage.dart';
import './providers/user_provider.dart';
import './providers/theme_provider.dart';
import './api/signupAPI.dart';
import './api/user_service.dart';
import './models/user_model.dart';
import '../ServicePage/waiting_screen_page.dart';

// 🔹 Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔹 Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 🔹 Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Background message: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Fix 1: Firebase init with timeout
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    print("✅ Firebase initialized");
  } catch (e) {
    print("❌ Firebase init failed: $e");
  }

  // ✅ Fix 2: Background handler
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("❌ BG handler error: $e");
  }

  // ✅ Fix 3: Local notifications setup
  try {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'customer_channel',
      'Customer Notifications',
      description: 'Channel for booking updates',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    print("❌ Notification setup error: $e");
  }

  // ✅ Fix 4: FCM Token with timeout
  try {
    final fcmToken = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 8));
    print("📡 Initial FCM Token: $fcmToken");

    if (fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcmToken", fcmToken);
    }
  } catch (e) {
    print("❌ FCM token error (continuing): $e");
  }

  // ✅ Fix 5: Token refresh listener
  try {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcmToken", newToken);
      print("📡 FCM Token Refreshed: $newToken");
    });
  } catch (e) {
    print("❌ Token refresh error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFCMListeners();
  }

  void _initFCMListeners() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 🔹 Request notification permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('🔔 User granted permission: ${settings.authorizationStatus}');

      // 🔹 Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📩 Foreground message: ${message.data}");
        _handleFCMNavigation(message);
      });

      // 🔹 When tapping notification (background → foreground)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📲 App opened from notification: ${message.data}");
        _handleFCMNavigation(message);
      });

      // 🔹 Handle initial notification (app was killed)
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print("🚀 App launched from killed state with: ${initialMessage.data}");
        _handleFCMNavigation(initialMessage);
      }
    } catch (e) {
      print("❌ FCM listener error: $e");
    }
  }

  void _handleFCMNavigation(RemoteMessage message) {
    final data = message.data;
    print("🚦 FCM Navigation handler called with data: $data");

    try {
      final status = data['status']?.toString().trim().toLowerCase();
      final serviceSpeed =
          data['serviceSpeed']?.toString().trim().toLowerCase();

      if (status == 'accepted' && data['bookingId'] != null) {
        if (serviceSpeed == 'fast service') {
          print("✅ Navigating to TrackingPage...");
          if (message.notification != null) {
            _showLocalNotification(message.notification!);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) => TrackingPage(
                  bookingId: data['bookingId'] ?? "",
                  engineerId: data['engineerId'] ?? "",
                  engineerPhone: data['engineerPhone'] ?? "",
                  engineerName: data['engineerName'] ?? "",
                  engineerLat:
                      double.tryParse(data['engineerLat'] ?? "0") ?? 0,
                  engineerLng:
                      double.tryParse(data['engineerLng'] ?? "0") ?? 0,
                  serviceType: data['serviceType'] ?? "",
                  problem: data['problem'] ?? "",
                  model: data['model'] ?? "",
                  otp: int.tryParse(data['otp'].toString()) ?? 0,
                  selfieImage: data['selfieImage'] ?? "",
                  address: data['address'] ?? "",
                  lat: double.tryParse(data['lat'] ?? "0") ?? 0,
                  lng: double.tryParse(data['lng'] ?? "0") ?? 0,
                ),
              ),
            );
          });
        } else if (serviceSpeed == 'scheduled service') {
          print("✅ Navigating to ScheduledWaitingPage...");
          if (message.notification != null) {
            _showLocalNotification(message.notification!);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    ScheduledWaitingPage(bookingData: data),
              ),
            );
          });
        } else {
          print("⚠️ Unknown serviceSpeed: '$serviceSpeed'");
        }
      } else {
        print("⚠️ Status not accepted or bookingId missing");
      }
    } catch (e) {
      print("❌ Error in navigation: $e");
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    }
  }

  // 🔹 Show local notification for foreground
  void _showLocalNotification(RemoteNotification notification) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'customer_channel',
      'Customer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Servicemate App',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/signup': (context) => const SignupPage(),
            '/home': (context) => const AppShell(),
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}

// Splash Screen with Auto Login Logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();

    // 🔹 Foreground FCM dialog alert
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showFCMAlert(
          title: message.notification!.title ?? "Notification",
          body: message.notification!.body ?? "",
        );
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userPhone = prefs.getString('user_phone');
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      Widget nextPage;

      if (isLoggedIn && userPhone != null && userPhone.isNotEmpty) {
        try {
          // ✅ API call with 10 second timeout
          final result = await SignupAPI.getUserByPhone(phone: userPhone)
              .timeout(const Duration(seconds: 10));

          if (result['success']) {
            UserService.updateUser(User.fromJson(result['user']));
            nextPage = const AppShell();
          } else {
            await prefs.clear();
            nextPage = hasSeenOnboarding
                ? const LoginPage()
                : const OnboardingScreen();
          }
        } on TimeoutException catch (_) {
          // ✅ Timeout ஆனா login page-க்கு போகும்
          print("⏱️ API Timeout - redirecting to login");
          nextPage = hasSeenOnboarding
              ? const LoginPage()
              : const OnboardingScreen();
        } catch (e) {
          print("❌ Error fetching user: $e");
          await prefs.clear();
          nextPage = hasSeenOnboarding
              ? const LoginPage()
              : const OnboardingScreen();
        }
      } else {
        nextPage = hasSeenOnboarding
            ? const LoginPage()
            : const OnboardingScreen();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    } catch (e) {
      print("❌ Splash error: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  void _showFCMAlert({required String title, required String body}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 120, width: 120),
            const SizedBox(height: 20),
            const Text(
              'Servicemate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Theme definitions
class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}