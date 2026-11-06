import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/chat.dart';
import 'screens/splash.dart';

import 'firebase_options.dart';
import 'screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
          primary: const Color.fromARGB(255, 63, 17, 177),
          onPrimary: const Color.fromARGB(255, 255, 255, 255),
          onSecondary: const Color.fromARGB(255, 0, 0, 0),
          secondary: const Color.fromARGB(255, 255, 255, 255),
          onBackground: const Color.fromARGB(255, 0, 0, 0),
          background: const Color.fromARGB(255, 255, 255, 255),
          onSurface: const Color.fromARGB(255, 0, 0, 0),
          surface: const Color.fromARGB(255, 255, 255, 255),
          error: const Color.fromARGB(255, 255, 0, 0),
          onError: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.light,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
