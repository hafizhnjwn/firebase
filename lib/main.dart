import 'package:firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase/screens/home.dart';
import 'package:firebase/services/notification_service.dart';
import 'package:firebase/screens/login.dart';
import 'package:firebase/screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Demo',
      routes: {
        'home': (context) => const HomeScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
      },
      initialRoute: 'login',
      navigatorKey: navigatorKey,
    );
  }
}

