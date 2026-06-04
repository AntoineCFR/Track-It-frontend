import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_it/services/auth_service.dart';
import 'package:track_it/widgets/auth_button.dart';
import 'package:track_it/widgets/email_password_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signInWithGoogle();

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const FlutterLogo(size: 100),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Track It',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Connect your Spotify and track your music',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email/Password Form
                    EmailPasswordForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isPasswordVisible: _isPasswordVisible,
                      onPasswordVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onSubmit: _handleEmailLogin,
                    ),
                    const SizedBox(height: 24),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[700])),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google Sign In Button
                    AuthButton(
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onPressed: _handleGoogleLogin,
                      isLoading: authService.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Apple Sign In Button (placeholder)
                    AuthButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onPressed: () async {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        await authService.signInWithApple();
                      },
                      isLoading: authService.isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Error Message
                    if (authService.errorMessage != null)
                      Text(
                        authService.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    // Loading Indicator
                    if (authService.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),

                    // Sign Up Link
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement sign up
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: const Color(0xFF1DB954),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
