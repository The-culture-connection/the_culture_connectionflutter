import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/content_view.dart';
import 'screens/registration_step1_screen.dart';
import 'screens/registration_step2_screen.dart';
import 'screens/registration_step3_screen.dart';
import 'screens/experience_level_screen.dart';
import 'screens/purposes_screen.dart';
import 'screens/gender_identity_screen.dart';
import 'screens/skills_main_categories_screen.dart';
import 'screens/skills_subcategories_screen.dart';
import 'screens/location_screen.dart';
import 'screens/edit_experience_purposes_screen.dart';
import 'screens/main_screen.dart';
import 'services/analytics_service.dart';
import 'services/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Analytics
  final analyticsService = AnalyticsService();
  await analyticsService.trackAppLaunch();
  
  // Initialize Performance Monitoring
  PerformanceMonitor.initialize();
  
  runApp(
    const ProviderScope(
      child: CultureConnectionApp(),
    ),
  );
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: CultureConnectionApp()));
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
}

class CultureConnectionApp extends StatelessWidget {
  const CultureConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culture Connection',
<<<<<<< HEAD
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF685BC6),
          secondary: Color(0xFFFF7E00),
          surface: Color(0xFF1d1d1e),
        ),
        scaffoldBackgroundColor: const Color(0xFF1d1d1e),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1d1d1e),
          selectedItemColor: Color(0xFF685BC6),
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: const ContentView(),
      routes: {
        '/registration-step1': (context) => const RegistrationStep1Screen(),
        '/registration-step2': (context) => const RegistrationStep2Screen(),
        '/registration-step3': (context) => const RegistrationStep3Screen(),
        '/experience-level': (context) => const ExperienceLevelScreen(),
        '/purposes': (context) => const PurposesScreen(),
        '/gender-identity': (context) => const GenderIdentityScreen(),
        '/skills-main-categories': (context) => const SkillsMainCategoriesScreen(
          type: 'offering',
          selectedMainCategories: [],
          selectedSubCategories: [],
        ),
        '/skills-seeking-main': (context) => const SkillsMainCategoriesScreen(
          type: 'seeking',
          selectedMainCategories: [],
          selectedSubCategories: [],
        ),
        '/skills-subcategories': (context) => const SkillsSubcategoriesScreen(),
        '/location': (context) => const LocationScreen(),
        '/edit-experience-purposes': (context) => const EditExperiencePurposesScreen(),
        '/main': (context) => const MainScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
=======
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2a2a2e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.electricOrange, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(), // More reliable than authStateChanges
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1d1d1e),
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.electricOrange,
              ),
            ),
          );
        }

        // If user is logged in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          // Clear all previous routes and show main app
          return const MainNavigationScreen();
        }

        // Otherwise show welcome screen
        return const WelcomeScreen();
      },
    );
  }
}
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
