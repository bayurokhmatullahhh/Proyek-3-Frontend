import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  static const List<_OnboardData> _pages = [
    _OnboardData(
      icon: Icons.biotech_rounded,
      tag: 'PREDIKSI AI',
      title: 'Prediksi Diagnosis\nAwal Akurat',
      subtitle:
          'Sistem AI kami menganalisis gejala-gejala yang kamu alami dan memberikan prediksi diagnosis awal dengan akurasi tinggi.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1628), Color(0xFF0D2140)],
      ),
      accentColor: AppTheme.primaryTeal,
      illustrationIcon: Icons.document_scanner_rounded,
    ),
    _OnboardData(
      icon: Icons.traffic_rounded,
      tag: 'PRIORITAS CERDAS',
      title: 'Antrian Lebih\nAdil & Efisien',
      subtitle:
          'Sistem otomatis menentukan tingkat urgensi pasien sehingga penanganan medis lebih tepat sasaran dan tidak ada yang terlewat.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D1F35), Color(0xFF102848)],
      ),
      accentColor: Color(0xFF3A7BD5),
      illustrationIcon: Icons.person_search_rounded,
    ),
    _OnboardData(
      icon: Icons.insights_rounded,
      tag: 'ANALISIS URBAN',
      title: 'Pantau Risiko\nKesehatan Urban',
      subtitle:
          'Dapatkan insight mendalam tentang risiko kesehatan berdasarkan gaya hidup urban kamu dan rekomendasi pencegahan yang personal.',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1628), Color(0xFF15203A)],
      ),
      accentColor: AppTheme.accentOrange,
      illustrationIcon: Icons.bar_chart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final current = _pages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(gradient: current.gradient),
        child: Stack(
          children: [
            // Dot pattern
            Positioned.fill(
              child: CustomPaint(painter: _DotPainter()),
            ),

            // Decorative blobs
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: -60,
              right: _currentPage == 0 ? -60 : (_currentPage == 1 ? -20 : -80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current.accentColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.28,
              left: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current.accentColor.withOpacity(0.06),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo mini
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.health_and_safety_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Smart Health',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // Skip button
                        if (_currentPage < _pages.length - 1)
                          GestureDetector(
                            onTap: _goToLogin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.12)),
                              ),
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Illustration area
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) =>
                          _IllustrationArea(page: _pages[index]),
                    ),
                  ),

                  // Content card
                  Expanded(
                    flex: 4,
                    child: AnimatedBuilder(
                      animation: _contentController,
                      builder: (_, __) => SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentOpacity,
                          child: _ContentCard(
                            page: current,
                            currentIndex: _currentPage,
                            total: _pages.length,
                            onNext: _nextPage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  final _OnboardData page;
  const _IllustrationArea({required this.page});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main illustration circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withOpacity(0.08),
              border: Border.all(
                  color: page.accentColor.withOpacity(0.15), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        page.accentColor.withOpacity(0.2),
                        page.accentColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                        color: page.accentColor.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    page.illustrationIcon,
                    color: page.accentColor,
                    size: 64,
                  ),
                ),
                // Floating badges
                Positioned(
                  top: 24,
                  right: 18,
                  child: _FloatingBadge(color: page.accentColor, icon: page.icon),
                ),
                Positioned(
                  bottom: 28,
                  left: 14,
                  child: _FloatingBadge(
                    color: Colors.white.withOpacity(0.9),
                    icon: Icons.check_rounded,
                    iconColor: page.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color? iconColor;
  const _FloatingBadge({required this.color, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final _OnboardData page;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  const _ContentCard({
    required this.page,
    required this.currentIndex,
    required this.total,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == total - 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: page.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: page.accentColor.withOpacity(0.3)),
            ),
            child: Text(
              page.tag,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: page.accentColor,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),

          const Spacer(),

          // Bottom row: dots + button
          Row(
            children: [
              // Page dots
              Row(
                children: List.generate(
                  total,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == currentIndex ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? page.accentColor
                          : Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Next / Get Started button
              GestureDetector(
                onTap: onNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLast ? 24 : 0,
                    vertical: 0,
                  ),
                  width: isLast ? null : 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [page.accentColor, page.accentColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isLast ? 18 : 28),
                    boxShadow: [
                      BoxShadow(
                        color: page.accentColor.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLast
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Mulai Sekarang',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeCap = StrokeCap.round;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OnboardData {
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color accentColor;
  final IconData illustrationIcon;
  const _OnboardData({
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    required this.illustrationIcon,
  });
}