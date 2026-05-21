import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/chatbot/chatbot_screen.dart';
import 'package:lottie/lottie.dart';

/// ============================================================
/// CHATBOT FAB — Floating chat button dengan animasi premium
/// Dipasang di MainPage, posisi kanan bawah
/// ============================================================

class ChatbotFab extends StatefulWidget {
  const ChatbotFab({super.key});

  @override
  State<ChatbotFab> createState() => _ChatbotFabState();
}

class _ChatbotFabState extends State<ChatbotFab>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _bounceCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    // Pulse ring animation (loop)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    // Bounce on tap
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    HapticFeedback.mediumImpact();
    await _bounceCtrl.forward();
    await _bounceCtrl.reverse();

    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatbotScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: GestureDetector(
        onTap: _onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final pulseValue = _pulseAnim.value;
                  return Transform.scale(
                    scale: pulseValue,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6C63FF)
                              .withOpacity((1.0 - (pulseValue - 1.0) * 2).clamp(0.0, 1.0)),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Main button
              ScaleTransition(
                scale: _bounceAnim,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C63FF), Color(0xFF3A7BD5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/elsabot.json',
                      width: 2000,
                      height: 2000,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Online badge
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AFF6F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4AFF6F).withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
