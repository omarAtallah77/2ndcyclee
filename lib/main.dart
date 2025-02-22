import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter/services.dart';




void main() async {

  // Lock screen orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,  // Optional, if you want to allow upside-down
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading indicator
        } else if (snapshot.hasData) {
          return HomeScreen(); // User is signed in, show home screen
        } else {
          return OnboardingScreen(); // User is not signed in, show onboarding screen
        }
      },
    );
  }
}
