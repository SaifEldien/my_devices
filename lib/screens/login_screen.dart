import 'package:flutter/material.dart';
import 'package:my_devices/funcs/loading_funcs.dart';
import 'package:my_devices/funcs/pref_funcs.dart';
import 'package:my_devices/funcs/show_toast_func.dart';

import '../Server/dio_client.dart';
import '../localDB/local_db.dart';
import '../main.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController emailController = TextEditingController(text: "saif@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "12345678");



  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedGradientBackground(
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
                      // Logo
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

                      const Text(
                        "Manage and track rentals easily",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Glass Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white) ,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.email,color: Colors.white,),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              style: TextStyle(color: Colors.white) ,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle:TextStyle(color: Colors.white) ,

                                prefixIcon: Icon(Icons.lock,color: Colors.white,),
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  showLoading(context, true);
                                  String email = emailController.text.trim().toLowerCase();
                                  String password = passwordController.text;
                                  try {
                                    final dioClient = DioClient();
                                    bool success = await dioClient.login(email, password).timeout(const Duration(seconds: 3));
                                    if (success) {
                                      var u = await dioClient.retrieveUser(email);
                                      currentUser = User.fromJson(u!);
                                      LocalDB().insertData('users', u);
                                      setPref('email', email);
                                      setPref('password', password);
                                      showLoading(context, false);
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AppInitializer()));
                                      return;
                                    }
                                    else {
                                      showToast(context, "An error Happened");
                                    }
                                  }
                                  catch (e) {
                                    print(e.toString()+"logIn error");
                                    showToast(context, e.toString());
                                  }
                                  showLoading(context, false);

                                },
                                child: const Text("Login"),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                    Color(0xFF1C1C2D), Color(0xFF7C3AED),
                    _controller.value)!,
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
