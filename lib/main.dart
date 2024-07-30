import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testproject/appcolor.dart';
import 'package:testproject/components/menu.dart';
import 'package:testproject/pages/login_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Defago',
        //floating button theme data
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),

        //eleventd button theme data
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),

        //input or textfield theme data
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
        ),

        //appbar theme style
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: AppColors.primaryColor,
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),

        //set all colors
        primaryColor: AppColors.primaryColor,
        secondaryHeaderColor: AppColors.primaryColor,
        focusColor: AppColors.secondaryColor,
        scaffoldBackgroundColor: Colors.white,

        //primary text style
        primaryTextTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Defago'),
        ),

        //text theme style
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimaryColor),
          headlineMedium: TextStyle(color: Colors.white),
        ),

        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

//Auth Wrapper used for checking authentication
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        // Show loading spinner while waiting for the future to complete
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if user is logged in or not
        if (snapshot.hasData) {
          // If user is logged in, navigate to home page
          return const Menu();
        } else {
          // If user is not logged in, navigate to login page
          return const LoginPage(email: '');
        }
      },
    );
  }
}
