import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'loading_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          title: 'RapidDelivery',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: Colors.orange,
              secondary: Colors.orangeAccent,
              surface: Colors.grey[900]!,
              onPrimary: Colors.black,
              onSecondary: Colors.black,
              onSurface: Colors.orange,
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.orange),
              displayMedium: TextStyle(color: Colors.orange),
              displaySmall: TextStyle(color: Colors.orange),
              headlineMedium: TextStyle(color: Colors.orange),
              headlineSmall: TextStyle(color: Colors.orange),
              titleLarge: TextStyle(color: Colors.orange),
              titleMedium: TextStyle(color: Colors.orange),
              titleSmall: TextStyle(color: Colors.orange),
              bodyLarge: TextStyle(color: Colors.orange),
              bodyMedium: TextStyle(color: Colors.orange),
              bodySmall: TextStyle(color: Colors.orange),
              labelLarge: TextStyle(color: Colors.orange),
              labelSmall: TextStyle(color: Colors.orange),
            ),
            appBarTheme: const AppBarTheme(
              color: Colors.black,
              titleTextStyle: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.orange),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
            useMaterial3: true,
          ),
          home: LoadingScreen(),
        );
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Failed to initialize the app. Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red[900],
                ),
                onPressed: () {
                  // Try to restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
