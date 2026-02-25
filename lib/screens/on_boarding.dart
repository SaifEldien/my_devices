import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:my_devices/funcs/pref_funcs.dart';

class SplashScreen extends StatefulWidget {
  final Widget screenToNevigate;

  const SplashScreen({super.key, required this.screenToNevigate});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LiquidController liquidController = LiquidController();
  int page = 0;
  List<Widget> pages = [];
  @override
  void initState() {
    pages = List.generate(pagesModels.length, (i) => buildPremiumPage(i));
    pages.add(widget.screenToNevigate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages,
            slideIconWidget: Positioned(
              bottom: 400,
              right: 20,
              child: Container(
                color: Colors.transparent,
                width: 50,
                height: 50,
                child: IconButton(
                  onPressed: () async {
                    if (page == pagesModels.length - 1) {
                      await setPref('isFirst', false);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => widget.screenToNevigate),
                      );
                    } else {
                      liquidController.animateToPage(page: page + 1, duration: 600);
                    }
                  },
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                ),
              ),
            ),
            positionSlideIcon: 0.5,
            enableLoop: false,

            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.liquidReveal,
            liquidController: liquidController,
            enableSideReveal: true,
            ignoreUserGestureWhileAnimating: true,
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pagesModels.length, (index) => buildDot(index)),
            ),
          ),
          if (page < pagesModels.length - 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: glassButton("Skip", () {
                liquidController.animateToPage(page: pagesModels.length - 1, duration: 600);
              }),
            ),
        ],
      ),
    );
  }

  Widget buildPremiumPage(int i) {
    final model = pagesModels[i];
    return SizedBox.expand(
      child: AnimatedGradientBackground(
        colors: model.gradient,
        child: SafeArea(
          top: false,
          bottom: false,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingIcon(icon: model.icon),
                  const SizedBox(height: 50),
                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      model.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: page == index ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: page == index ? const LinearGradient(colors: [Colors.white, Colors.white70]) : null,
        color: page == index ? null : Colors.white.withOpacity(0.4),
      ),
    );
  }

  Widget glassButton(String text, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void pageChangeCallback(int index) async {


    setState(() {
      page = index;
    });
    print(index);
    if (index == 3) {

      await setPref('isFirst', false);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.screenToNevigate));
    }
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.colors, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + controller.value * 2, -1),
              end: Alignment(1 - controller.value * 2, 1),
              colors: widget.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class FloatingIcon extends StatefulWidget {
  final IconData icon;

  const FloatingIcon({super.key, required this.icon});

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, -10 * controller.value), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 25, spreadRadius: 2)],
        ),
        child: Icon(widget.icon, size: 90, color: Colors.white),
      ),
    );
  }
}

class OnboardModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  OnboardModel({required this.icon, required this.title, required this.subtitle, required this.gradient});
}

final List<OnboardModel> pagesModels = [
  OnboardModel(
    icon: Icons.devices_other_rounded,
    title: "All Your Devices. One Place.",
    subtitle: "Easily organize, track, and manage every device you own.",
    gradient: const [Color(0xFF706FBB), Color(0xFF7C3AED)],
  ),
  OnboardModel(
    icon: Icons.handshake_rounded,
    title: "Track Rentals Effortlessly",
    subtitle: "Know who rented what, for how long, and for how much.",
    gradient: const [Color(0xFF312F57), Color(0xFF7C3AED)],
  ),
  OnboardModel(
    icon: Icons.location_on_rounded,
    title: "Never Lose Track",
    subtitle: "Save renter locations and navigate with one tap.",
    gradient: const [Color(0xFF1C1C2D), Color(0xFF7C3AED)],
  ),
];

class RightNotchClipper extends CustomClipper<Path> {
  final double radius;

  RightNotchClipper({this.radius = 80});

  @override
  Path getClip(Size size) {
    final path = Path();

    final notchCenterY = size.height / 2;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // go down until notch start
    path.lineTo(size.width, notchCenterY - radius);

    // create inward curve (the notch)
    path.quadraticBezierTo(size.width - radius * 2, notchCenterY, size.width, notchCenterY + radius);

    // continue down
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
