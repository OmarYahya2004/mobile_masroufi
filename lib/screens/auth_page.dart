import 'package:flutter/material.dart';
import '../data/remote/auth_service.dart';
import '../core/constants/colors.dart'; // Import your colors file

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  final String appFont = 'Poppins'; // Custom font consistency

  void _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? result;
    if (_isLogin) {
      result = await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
    } else {
      result = await _authService.signUp(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim());
    }

    if (result != null && mounted) {
      setState(() {
        _errorMessage = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme setup
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final inputFill = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryBlue, // Use brand blue for main headers
                  fontFamily: appFont
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor, fontFamily: appFont),
                  decoration: InputDecoration(
                    labelText: 'Full Name', 
                    labelStyle: TextStyle(color: textSecondary, fontFamily: appFont),
                    filled: true, 
                    fillColor: inputFill, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor, fontFamily: appFont),
                decoration: InputDecoration(
                  labelText: 'Email', 
                  labelStyle: TextStyle(color: textSecondary, fontFamily: appFont),
                  filled: true, 
                  fillColor: inputFill, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: textColor, fontFamily: appFont),
                decoration: InputDecoration(
                  labelText: 'Password', 
                  labelStyle: TextStyle(color: textSecondary, fontFamily: appFont),
                  filled: true, 
                  fillColor: inputFill, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!, 
                    style: TextStyle(color: AppColors.errorRed, fontFamily: appFont), 
                    textAlign: TextAlign.center
                  ),
                ),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    ) 
                  : Text(
                      _isLogin ? 'Login' : 'Sign Up', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: appFont)
                    ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Need an account? Sign up' : 'Already have an account? Login', 
                  style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontFamily: appFont)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}