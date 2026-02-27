import 'package:flutter/foundation.dart';
import 'package:my_devices/core/connectivity/connectivity_service.dart';
import 'package:my_devices/core/constants/app_config.dart';
import 'package:my_devices/core/core.dart';

import '../../../core/funcs/is_valid_email.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController emailController = TextEditingController(text: "saif@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "12345678");
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.stop();

    _controller.dispose();
    super.dispose();
  }

  bool _isLocalLoading = false;

  void _handleLogin() async {
    setState(() => _isLocalLoading = true);
    final authProvider = context.read<AuthProvider>();
    bool success = await authProvider.manualLogin(
      emailController.text.toLowerCase().trim(),
      passwordController.text,
    );
    if (success) {
      if (kDebugMode) {
        print("Success: Redirecting via MaterialApp home...");
      }
    } else {
      if (mounted) {
        setState(() => _isLocalLoading = false);
        showToast("login_failed".tr(), isError: true);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isLocalLoading,
            child: TickerMode(
              enabled: !authProvider.isAuthenticated,
              child: AnimatedGradientBackground(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              const Icon(Icons.devices, size: 70, color: Colors.white),
                              const SizedBox(height: 16),
                              const Text(
                                "Device Manager",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("app_subtitle".tr(), style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: emailController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "email_label".tr(),
                                          labelStyle: TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.email, color: Colors.white),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "required".tr();
                                          }
                                          if (!isValidEmail(value.toLowerCase().trim())) {
                                            return "invalid_email".tr();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        obscureText: _obscurePassword,
                                        controller: passwordController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "password_label".tr(),
                                          labelStyle: TextStyle(color: Colors.white),
                                          hintStyle: TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty || value.length < 6) {
                                            return "password_length_error".tr();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (!_formKey.currentState!.validate()) return;
                                            _handleLogin();
                                          },
                                          child: Text("login_button".tr()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (kIsFirebase)
                                TextButton(
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    String email = emailController.text.toLowerCase().trim();
                                    if (email.isEmpty || !isValidEmail(email)) {
                                      showToast("forgot_password_hint".tr(), isError: true);
                                      return;
                                    } else if (!await ConnectivityService.hasConnection()) {
                                      return;
                                    }
                                    else if (!context.mounted) {
                                      return;
                                    }
                                    showCustomDialog(
                                      context,
                                      onAccept: () async {
                                        await authProvider.restPassword(email);
                                      },
                                      icon: Icons.password,
                                      color: Colors.deepPurple.shade900,
                                      title: "${"send_password_title".tr()}$email",
                                    );
                                  },
                                  child: Text("forgot_password".tr(), style: TextStyle(color: Colors.white)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isLocalLoading ? 1.0 : 0.0,
            child: _isLocalLoading
                ? Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(Color(0xFF1C1C2D), Color(0xFF7C3AED), _controller.value)!,
                const Color(0xFF0F172A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
