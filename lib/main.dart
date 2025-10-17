import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: CultureConnectionApp()));
}

class CultureConnectionApp extends ConsumerWidget {
  const CultureConnectionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Culture Connection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.deepPurple,
          secondary: AppColors.electricOrange,
          surface: const Color(0xFF1d1d1e),
        ),
        scaffoldBackgroundColor: const Color(0xFF1d1d1e),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1d1d1e),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainNavigationScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.electricOrange,
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
