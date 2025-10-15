
import 'package:firebase_auth_demo/home/home.dart';
import 'package:firebase_auth_demo/auth/login.dart';
import 'package:firebase_auth_demo/auth/sign_up.dart';
import 'package:firebase_auth_demo/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context)=> const SplashScreen(),
        '/login':(context)=> const LoginScreen(),
        '/register':(context)=> const RegisterScreen(),
        '/home':(context)=> const HomeScreen(),
      },
    );
  }
}
