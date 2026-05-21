
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Nanti data ini dari API Laravel /api/promos
// Saat ini pakai data statis dulu, struktur sudah siap untuk API

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _pageCtrl = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoTimer;

  // Data promo — nanti dari GET /api/promos
  static const List<_PromoData> _promos = [
    _PromoData(
      tag: 'GRATIS',
      title: 'Diagnosis AI\nGratis Setiap Hari',
      subtitle: 'Cek kondisi kesehatan kapan saja',
      gradient: LinearGradient(
        colors: [Color(0xFF0A1628), Color(0xFF1A3A5C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      accentColor: Color(0xFF00D4AA),
      icon: Icons.auto_awesome_rounded,
    ),
    _PromoData(
      tag: 'INFO',
      title: 'Pahami Hasil\nDiagnosismu',
      subtitle: 'Kami Menjelaskan hasil dengan detail',
      gradient: LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF3A7BD5)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      accentColor: Color(0xFFF59E0B),
      icon: Icons.biotech_rounded,
    ),
    _PromoData(
      tag: 'TIPS',
      title: 'Gaya Hidup Sehat\nuntuk Urban',
      subtitle: 'Rekomendasi personal dari AI',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      accentColor: Colors.white,
      icon: Icons.spa_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _promos.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 180,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: _promos.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _pageCtrl,
              builder: (_, child) {
                double scale = 1.0;
                if (_pageCtrl.position.haveDimensions) {
                  scale = 1 - ((_pageCtrl.page! - index).abs() * 0.05)
                      .clamp(0.0, 0.05);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: _PromoCard(
                promo: _promos[index],
                onTap: () => _showPromoDetail(context, _promos[index]),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 12),

      // Dot indicators
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_promos.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _currentPage ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? AppTheme.primaryTeal
                : AppTheme.textMuted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        )),
      ),
    ]);
  }

  void _showPromoDetail(BuildContext context, _PromoData promo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: promo.gradient,
            borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(promo.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(promo.title.replaceAll('\n', ' '),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(promo.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7),
                  fontSize: 13, fontFamily: 'Poppins')),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text('Tutup',
                  style: TextStyle(
                      color: promo.gradient.colors.first,
                      fontWeight: FontWeight.w700,
                      fontSize: 14, fontFamily: 'Poppins'))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final _PromoData promo;
  final VoidCallback onTap;
  const _PromoCard({required this.promo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
            gradient: promo.gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.elevatedShadow),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          // Decorative circles
          Positioned(right: -30, top: -30, child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06)))),
          Positioned(right: 60, bottom: -50, child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04)))),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: promo.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: promo.accentColor.withOpacity(0.4))),
                    child: Text(promo.tag,
                        style: TextStyle(color: promo.accentColor,
                            fontWeight: FontWeight.w800, fontSize: 9,
                            letterSpacing: 1, fontFamily: 'Poppins')),
                  ),
                  const SizedBox(height: 10),
                  Text(promo.title,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.w800,
                          height: 1.25, letterSpacing: -0.3,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  Text(promo.subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.65),
                          fontSize: 11, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('Selengkapnya →',
                        style: TextStyle(
                            color: promo.gradient.colors.first,
                            fontWeight: FontWeight.w700, fontSize: 11,
                            fontFamily: 'Poppins')),
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1)),
                child: Icon(promo.icon,
                    color: Colors.white.withOpacity(0.9), size: 36),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _PromoData {
  final String tag, title, subtitle;
  final LinearGradient gradient;
  final Color accentColor;
  final IconData icon;
  const _PromoData({
    required this.tag, required this.title, required this.subtitle,
    required this.gradient, required this.accentColor, required this.icon,
  });
}


// // KODE BARU 12-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class PromoBanner extends StatefulWidget {
//   const PromoBanner({super.key});

//   @override
//   State<PromoBanner> createState() => _PromoBannerState();
// }

// class _PromoBannerState extends State<PromoBanner> {

//   final PageController _pageController =
//       PageController(viewportFraction: 0.9);

//   int _currentPage = 0;

//   final List<_PromoData> _promos = const [

//     _PromoData(
//       title: 'Konsultasi Dokter\nGratis Hari Ini',
//       subtitle: 'Hemat hingga 100%',
//       badge: 'GRATIS',
//       gradient: LinearGradient(
//         colors: [Color(0xFF0A1628), Color(0xFF1A3A5C)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       accentColor: Color(0xFF00D4AA),
//       icon: Icons.medical_services_rounded,
//     ),

//     _PromoData(
//       title: 'Cek Lab Lengkap\nDiskon 30%',
//       subtitle: 'Kode: SMARTHEALTH30',
//       badge: '30% OFF',
//       gradient: LinearGradient(
//         colors: [Color(0xFF6C63FF), Color(0xFF3A7BD5)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       accentColor: Color(0xFFF59E0B),
//       icon: Icons.biotech_rounded,
//     ),

//     _PromoData(
//       title: 'Vaksinasi\nHomecare',
//       subtitle: 'Mulai dari Rp 50.000',
//       badge: 'HEMAT',
//       gradient: LinearGradient(
//         colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       accentColor: Colors.white,
//       icon: Icons.vaccines_rounded,
//     ),
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Column(
//       children: [

//         SizedBox(
//           height: 200,
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: _promos.length,
//             onPageChanged: (i) => setState(() => _currentPage = i),

//             itemBuilder: (context, index) {

//               return AnimatedBuilder(
//                 animation: _pageController,

//                 builder: (context, child) {

//                   double scale = 1.0;

//                   if (_pageController.position.haveDimensions) {

//                     scale = _pageController.page! - index;
//                     scale = (1 - (scale.abs() * 0.1)).clamp(0.9, 1.0);
//                   }

//                   return Transform.scale(
//                     scale: scale,
//                     child: child,
//                   );
//                 },

//                 child: _PromoCard(
//                   promo: _promos[index],
//                 ),
//               );
//             },
//           ),
//         ),

//         const SizedBox(height: 12),

//         /// PAGE INDICATOR
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             _promos.length,
//             (i) => AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: const EdgeInsets.symmetric(horizontal: 3),
//               width: i == _currentPage ? 20 : 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: i == _currentPage
//                     ? AppTheme.primaryTeal
//                     : AppTheme.textMuted,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PromoCard extends StatelessWidget {

//   final _PromoData promo;

//   const _PromoCard({required this.promo});

//   @override
//   Widget build(BuildContext context) {

//     final width = MediaQuery.of(context).size.width;

//     final iconSize = width < 360 ? 32.0 : 40.0;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 6),

//       decoration: BoxDecoration(
//         gradient: promo.gradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: AppTheme.elevatedShadow,
//       ),

//       clipBehavior: Clip.hardEdge,

//       child: Stack(
//         children: [

//           /// DECORATION CIRCLES
//           Positioned(
//             right: -30,
//             top: -30,
//             child: Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),

//           Positioned(
//             right: 60,
//             bottom: -50,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.04),
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(22),

//             child: Row(
//               children: [

//                 /// LEFT CONTENT
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,

//                     children: [

//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),

//                         decoration: BoxDecoration(
//                           color: promo.accentColor.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(
//                             color: promo.accentColor.withOpacity(0.4),
//                           ),
//                         ),

//                         child: Text(
//                           promo.badge,
//                           style: TextStyle(
//                             color: promo.accentColor,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 10,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(
//                         promo.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w700,
//                           height: 1.3,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       Text(
//                         promo.subtitle,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 12,
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),

//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                         ),

//                         child: Text(
//                           'Ambil Promo',
//                           style: TextStyle(
//                             color: promo.gradient.colors.first,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 /// RIGHT ICON
//                 Container(
//                   width: 80,
//                   height: 80,

//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.1),
//                   ),

//                   child: Icon(
//                     promo.icon,
//                     color: Colors.white.withOpacity(0.9),
//                     size: iconSize,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PromoData {

//   final String title;
//   final String subtitle;
//   final String badge;
//   final LinearGradient gradient;
//   final Color accentColor;
//   final IconData icon;

//   const _PromoData({
//     required this.title,
//     required this.subtitle,
//     required this.badge,
//     required this.gradient,
//     required this.accentColor,
//     required this.icon,
//   });
// }