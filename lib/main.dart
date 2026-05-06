

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/file_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/file_list_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

/// Entry point — initializes Hive and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive for local storage (works on web + mobile)
  await Hive.initFlutter();
  runApp(const SmartFileShareApp());
}

/// Root widget — sets up MultiProvider for auth + file state
class SmartFileShareApp extends StatelessWidget {
  const SmartFileShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider for login/signup
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // File provider for file management
        ChangeNotifierProvider(create: (_) => FileProvider()),
      ],
      child: MaterialApp(
        title: 'SmartShare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textPrimary),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        // AuthWrapper checks session and shows Login or Home
        home: const AuthWrapper(),
      ),
    );
  }
}

/// AuthWrapper — checks if user is logged in and routes accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Check if user has an active session
  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkSession();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show splash screen while checking session
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.folder_shared, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('SmartShare', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ]),
        ),
      );
    }

    // Show login or home based on auth state
    final auth = Provider.of<AuthProvider>(context);
    return auth.isLoggedIn ? const FileListScreen() : const LoginScreen();
  }
}

