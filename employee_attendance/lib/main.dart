import 'package:employee_attendance/screens/login_screen.dart';
import 'package:employee_attendance/screens/home_screen.dart';
import 'package:employee_attendance/services/auth_service.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with your project credentials
  const supabaseUrl = 'https://iolgneayeffjwuqfupdq.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvbGduZWF5ZWZmand1cWZ1cGRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4NDMzMjYsImV4cCI6MjA2MTQxOTMyNn0.myrtYSRt1G9_QoHjrzqAu0t2JS9CWEmF-1L249YqKkw';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => DbService()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'employee_attendance',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
          },
      ),
    );
  }
}
