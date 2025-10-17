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
          print('🔐 Auth State Changed - User: ${user?.uid ?? 'null'}');
          if (user != null) {
            print('✅ Navigating to MainNavigationScreen');
            return const MainNavigationScreen();
          } else {
            print('❌ Navigating to LoginScreen');
            return const LoginScreen();
          }
        },
        loading: () {
          print('⏳ Auth State Loading...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.electricOrange,
              ),
            ),
          );
        },
        error: (error, stack) {
          print('❌ Auth State Error: $error');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
