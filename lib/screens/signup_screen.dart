
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'file_list_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle signup
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      // Navigate to home and clear stack
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! ✓'),
              backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FileListScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Text('Create Account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Sign up to start sharing files',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 32),

                // Name field
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'At least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textHint),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Signup button
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Login',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
