import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:my_devices/providers/auth_provider.dart';

import '../../../core/core.dart';

class OnBoardingScreen extends StatefulWidget {
  final Widget screenToNavigate;

  const OnBoardingScreen({super.key, required this.screenToNavigate});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> with SingleTickerProviderStateMixin {
  final LiquidController liquidController = LiquidController();
  late AnimationController _iconAnimationController;
  int page = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preparePages();
  }

  void _preparePages() {
    bool isAr = context.locale.languageCode == 'ar';
    List<Widget> basePages = List.generate(pagesModels.length, (i) => buildPremiumPage(i));
    if (isAr) {
      pages = [widget.screenToNavigate, ...basePages.reversed,Container(color: Colors.deepPurple,)];
    } else {
      pages = [...basePages, widget.screenToNavigate];
    }
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = context.locale.languageCode == 'ar';
    int initialPage = isAr ? pages.length - 2 : 0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: isAr ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
            child: LiquidSwipe(
              pages: pages.map((p) => Transform(
                alignment: Alignment.center,
                transform: isAr ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
                child: p,
              )).toList(),
              liquidController: liquidController,
              initialPage: initialPage,
              slidePercentCallback: (horizontal, vertical) {
                bool isAr = context.locale.languageCode == 'ar';

                // في العربي: إذا كان في P1 (Index 3) ويحاول السحب لليمين (horizontal < 0)
                if (isAr && page == 0 && horizontal < 0) {
                  // لا تفعل شيئاً أو يمكنك عمل haptic feedback لتنبيهه
                }
              },
              onPageChangeCallback: pageChangeCallback,
              waveType: WaveType.liquidReveal,
              fullTransitionValue: 600,
              enableSideReveal: true,
              enableLoop: false,
              ignoreUserGestureWhileAnimating: true,
              slideIconWidget: _buildAnimatedIcon(isAr),
              positionSlideIcon: 0.5,
            ),
          ),

          if (!_isFinalScreen(isAr))
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pagesModels.length,
                      (index) => buildDot(index),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: isAr ? null : 5,
              left: isAr ? 5 : null,
              child: glassButton("onboarding_skip".tr(), () {
                int loginPageIndex = isAr ? 0 : pages.length - 1;
                liquidController.animateToPage(
                    page: loginPageIndex,
                    duration: 1500
                );
              }),
            ),
        ],
      ),
    );
  }

  bool _isFinalScreen(bool isAr) {
    return isAr ? (liquidController.currentPage == 0) : (liquidController.currentPage == pages.length - 1);
  }

  Widget _buildAnimatedIcon(bool isAr) {
    return InkWell(
      onTap: (){
        bool isAr = context.locale.languageCode == 'ar';
        if (page == pagesModels.length - 1) {
          int loginPageIndex = isAr ? 0 : pages.length - 1;
          liquidController.animateToPage(page: loginPageIndex, duration: 800);
        } else {
          int nextIndex = isAr ? (pages.length - 2 - (page + 1)) : (page + 1);
          liquidController.animateToPage(page: nextIndex, duration: 600);
        }
        },
      child: AnimatedBuilder(
        animation: _iconAnimationController,
        builder: (context, child) {
          bool isLastPage = _isFinalScreen(isAr);
          double xOffset = !isLastPage ? (8 * _iconAnimationController.value) : 0;
          if (isLastPage) return const SizedBox.shrink();
          return Transform.translate(
            offset: page != 0 ? Offset(0, 0) :  Offset(isAr ? -xOffset*2 : xOffset, 0),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isLastPage ? Colors.white.withValues(alpha:0.2) : Colors.transparent,
                boxShadow: !isLastPage ? [
                  BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 15 * _iconAnimationController.value)
                ] : [],
              ),
              child: Transform.translate(
                offset: Offset(isAr ? -xOffset : xOffset, 0),
                child: Icon(
                  isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void pageChangeCallback(int index) async {
    bool isAr = context.locale.languageCode == 'ar';
    if (isAr&&index==1) {
      pages[2] = widget.screenToNavigate ;
      setState(() {

      });
    }

    if (isAr&&index==2) {
      pages[2] = buildPremiumPage(1);
      setState(() {

      });
    }


    if (isAr && index == pages.length - 1) {
      await Future.delayed(Duration(milliseconds: 1));
      liquidController.jumpToPage(page: pages.length - 2);
      return; // توقف هنا ولا تكمل تحديث الـ logicalIndex
    }
    int logicalIndex;
    if (isAr) {
      logicalIndex = (pages.length - 2) - index;
    } else {
      logicalIndex = index;
    }
    bool reachedLogin = isAr ? (index == 0) : (index == pages.length - 1);
    if (reachedLogin) {
      setState(() => page = pagesModels.length);
      await _finishOnboarding();
    } else {
      if (logicalIndex >= 0 && logicalIndex < pagesModels.length) {
        setState(() {
          page = logicalIndex;
        });
      }
    }
  }

  Future<void> _finishOnboarding() async {
     await setPref('isFirst', false);
     if (!mounted) return;
     context.read<AuthProvider>().setIsFirst(newIsFirst: false);
  }

  Widget buildPremiumPage(int i) {
    final model = pagesModels[i];
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: model.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingIcon(icon: model.icon),
              const SizedBox(height: 50),
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                model.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
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
        color: page == index ? Colors.white : Colors.white.withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// --- المكونات الإضافية ---
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
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform.translate(offset: Offset(0, -10 * controller.value), child: child),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 25, spreadRadius: 2)],
        ),
        child: Icon(widget.icon, size: 90, color: Colors.white),
      ),
    );
  }
}

// --- موديل الصفحات ---
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
    title: "onboarding_page1_title".tr(),
    subtitle: "onboarding_page1_subtitle".tr(),
    gradient: const [Color(0xFF1C1C2D), Color(0xFF7C3AED)],
  ),
  OnboardModel(
    icon: Icons.handshake_rounded,
    title: "onboarding_page2_title".tr(),
    subtitle: "onboarding_page2_subtitle".tr(),
    gradient: const [Color(0xFF312F57), Color(0xFF7C3AED)],
  ),
  OnboardModel(
    icon: Icons.location_on_rounded,
    title: "onboarding_page3_title".tr(),
    subtitle: "onboarding_page3_subtitle".tr(),
    gradient: const [Color(0xFF706FBB), Color(0xFF7C3AED)],
  ),
];
