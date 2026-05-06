/// ===================================================================
/// MAIN.DART - Entry point of the Smart File Share application
/// ===================================================================
/// This file initializes Hive (local database), sets up Provider for
/// state management, and defines the app theme and home screen.
/// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/file_provider.dart';
import 'screens/file_list_screen.dart';
import 'utils/constants.dart';

/// Entry point — initializes Hive and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (works on web + mobile)
  await Hive.initFlutter();

  runApp(const SmartFileShareApp());
}

/// Root widget of the application
/// Uses ChangeNotifierProvider to provide FileProvider to the widget tree
class SmartFileShareApp extends StatelessWidget {
  const SmartFileShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Create the FileProvider instance and make it available app-wide
      create: (_) => FileProvider(),
      child: MaterialApp(
        title: 'SmartShare',
        debugShowCheckedModeBanner: false,
        // App-wide theme configuration
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          // Typography
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            bodyMedium: TextStyle(color: AppColors.textPrimary),
          ),
          // AppBar theme
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        // Home screen is the file list
        home: const FileListScreen(),
      ),
    );
  }
}
now add download file option 