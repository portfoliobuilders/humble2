import 'package:flutter/material.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:humble/view/user/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // This ensures Flutter is initialized before we run the app
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start with SplashScreen instead of directly going to SignInPage
      home: SplashScreen(),
    );
  }
}
