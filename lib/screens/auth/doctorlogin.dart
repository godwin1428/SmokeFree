import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/core/validators.dart';
import 'package:smokefree/core/session_manager.dart';
import 'package:smokefree/doctorhome.dart';
import 'package:smokefree/services/cross_role_sync_service.dart';
import 'package:smokefree/theme/app_colors.dart';
import 'package:smokefree/ip.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  _DoctorLoginPageState createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final String url = ip + 'doclog.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.toString().toLowerCase().contains("success")) {
          doctid = username;
          await SessionManager().saveUserSession(
            username: username,
            role: 'doctor',
          );
          _showToast("Login successful");
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorHomePage()),
          );
          return;
        }
      }
    } catch (_) {}

    // Cross-Role Sync Check: Check credentials provisioned by Admin
    final isSyncAuthenticated = await CrossRoleSyncService().authenticateDoctor(username, password);
    if (isSyncAuthenticated) {
      doctid = username;
      final docDetails = await CrossRoleSyncService().findDoctor(username);
      await SessionManager().saveUserSession(
        username: username,
        role: 'doctor',
        name: docDetails?['name'] ?? 'Dr. $username',
        email: docDetails?['email'] ?? '',
        contact: docDetails?['contact'] ?? '',
        age: docDetails?['age'] ?? '',
        gender: docDetails?['gender'] ?? '',
      );
      _showToast("Clinical staff login verified");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorHomePage()),
      );
      return;
    }

    _showToast("Invalid doctor credentials");
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            primary: false,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Clinician Portal',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Access patient cohorts & PFT spirometry curves',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Image
              Image.asset(
                'assets/dl.png',
                height: 190,
                fit: BoxFit.contain,
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 25),

              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    // Doctor ID Input
                    TextFormField(
                      controller: _usernameController,
                      validator: AppValidators.validateDoctorId,
                      decoration: InputDecoration(
                        hintText: 'Doctor ID / Username',
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.mintFresh),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.lightCardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.lightCardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.mintFresh, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.coralRed),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.coralRed, width: 2),
                        ),
                        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.coralRed),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: AppValidators.validatePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mintFresh),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSubtle,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.lightCardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.lightCardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.mintFresh, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.coralRed),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.coralRed, width: 2),
                        ),
                        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.coralRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showToast("Contact hospital administrator to reset password");
                  },
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Login CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Log in to Portal',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}
