import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
}

class CultureConnectionApp extends StatelessWidget {
  const CultureConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culture Connection',
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