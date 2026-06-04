import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../auth/onboarding_screen.dart';
import '../home/home_screen.dart'; // nanti diganti cek session

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _exitController;

  // Animations
  late Animation<double> _bgScale;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // BG zoom in
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgScale = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOutCubic),
    );

    // Logo pop in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Pulse ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // BG zoom
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Logo pop
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Text slide
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));

    // Exit
    _pulseController.stop();
    await _exitController.forward();

    if (mounted) {
      // TODO: cek SharedPreferences apakah user sudah login
      // bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      // if (isLoggedIn) navigate to MainPage else OnboardingScreen

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FadeTransition(
        opacity: _exitOpacity,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (_, __) => Transform.scale(
            scale: _bgScale.value,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F9F7),
                    Color(0xFFE8F5F1),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // ── Decorative circles ──
                  _DecorCircle(
                    size: 450,
                    top: -180,
                    right: -160,
                    color: const Color(0xFF00C9A7).withOpacity(0.08),
                  ),
                  _DecorCircle(
                    size: 350,
                    bottom: -140,
                    left: -150,
                    color: const Color(0xFF0A1628).withOpacity(0.04),
                  ),
                  _DecorCircle(
                    size: 180,
                    top: size.height * 0.3,
                    right: -50,
                    color: const Color(0xFF00C9A7).withOpacity(0.05),
                  ),

                  // ── Grid dots pattern ──
                  Positioned.fill(
                    child: CustomPaint(painter: _DotPatternPainter()),
                  ),

                  // ── Center content ──
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pulse + Logo
                        ScaleTransition(
                          scale: _pulse,
                          child: AnimatedBuilder(
                            animation: _logoController,
                            builder: (_, __) => Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: _LogoWidget(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Text
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (_, __) => SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textOpacity,
                              child: _BrandText(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom loading bar ──
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) => Opacity(
                      opacity: _textOpacity.value,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 48,
                          ),
                          child: _LoadingBar(),
                        ),
                      ),
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
}

// ── Sub-widgets ──

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C9A7), Color(0xFF00B89B), Color(0xFF009B87)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C9A7).withOpacity(0.35),
            blurRadius: 60,
            spreadRadius: 15,
          ),
          BoxShadow(
            color: const Color(0xFF00C9A7).withOpacity(0.15),
            blurRadius: 120,
            spreadRadius: 40,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 2.5,
              ),
            ),
          ),

          // Middle ring - accent
          Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
          ),

          // Icon container dengan background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C9A7).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_puskesmas.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // Premium badge
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B5B), Color(0xFFFF5E42)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B5B).withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Poppins'),
            children: [
              TextSpan(
                text: 'PuskesmasKU\n',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1628),
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'Health AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00C9A7),
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00C9A7).withOpacity(0.1),
                const Color(0xFF00C9A7).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00C9A7).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C9A7).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'AI-Powered Healthcare Intelligence',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF00C9A7),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBar extends StatefulWidget {
  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _progress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (_, __) => Container(
            width: 200,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF00C9A7).withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF00C9A7),
                      const Color(0xFF00E0BA),
                      const Color(0xFF00C9A7).withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C9A7).withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Initializing Healthcare Platform...',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: const Color(0xFF0A1628).withOpacity(0.5),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double? top, bottom, left, right;
  final Color color;
  const _DecorCircle({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C9A7).withOpacity(0.06)
      ..strokeCap = StrokeCap.round;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
