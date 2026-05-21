import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/home/header.dart';
import '../../widgets/home/halocoins_card.dart';
import '../../widgets/home/menu_grid.dart';
import '../../widgets/home/promo_banner.dart';
import '../../widgets/home/article_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  double _headerOpacity = 0;

  // User data
  Map<String, dynamic> _user = {};
  bool _isLoadingUser = true;

  // Stats dari API
  int _diagnosisCount = 0;
  int _smartPts       = 0;

  // Health score — kalkulasi dari riwayat diagnosis
  int _healthScore = 0;
  String _healthScoreLabel = 'Belum ada data';
  Color  _healthScoreColor = AppTheme.textMuted;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final opacity = (_scrollCtrl.offset / 100).clamp(0.0, 1.0);
      if (opacity != _headerOpacity) setState(() => _headerOpacity = opacity);
    });
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);

    // Load cache lokal dulu
    final cached = await AuthService.getUserData();
    if (mounted) setState(() { _user = cached; _isLoadingUser = false; });

    // Fetch fresh di background
    final fresh = await AuthService.fetchUserProfile();
    if (fresh != null && mounted) setState(() => _user = fresh);

    // Load history untuk hitung health score
    await _loadHealthScore();
  }

  Future<void> _loadHealthScore() async {
    try {
      final history = await ApiService.getDiagnosisHistory();
      if (!mounted) return;

      _diagnosisCount = history.length;

      if (history.isEmpty) {
        setState(() {
          _healthScore      = 0;
          _healthScoreLabel = 'Belum ada data';
          _healthScoreColor = AppTheme.textMuted;
          _smartPts         = 0;
        });
        return;
      }

      // Hitung skor dari urgency level terakhir 5 riwayat
      final recent = history.take(5).toList();
      int score = 100;
      for (final item in recent) {
        switch (item.urgencyLevel.toLowerCase()) {
          case 'urgent': score -= 20; break;
          case 'semi':   score -= 10; break;
          default:       score -= 3;  break;
        }
      }
      score = score.clamp(10, 100);

      // Smart pts = diagnosis count × 10
      final pts = _diagnosisCount * 10;

      // Label berdasarkan skor
      String label; Color color;
      if (score >= 80) {
        label = 'Sangat Baik 💪'; color = AppTheme.success;
      } else if (score >= 60) {
        label = 'Cukup Baik 👍'; color = AppTheme.warning;
      } else {
        label = 'Perlu Perhatian ⚠️'; color = AppTheme.danger;
      }

      setState(() {
        _healthScore      = score;
        _healthScoreLabel = label;
        _healthScoreColor = color;
        _smartPts         = pts;
      });
    } catch (_) {
      // Gagal load history tidak apa-apa
    }
  }

  String get _displayName {
    final n = _user['name']?.toString() ?? '';
    if (n.isEmpty) return 'Pengguna';
    return n.split(' ').first; // hanya first name di header
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // ── Main scroll ──────────────────────────────────────────
          RefreshIndicator(
            color: AppTheme.primaryTeal,
            onRefresh: _loadUserData,
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // Header (profil, greeting, search)
                SliverToBoxAdapter(
                  child: HomeHeader(
                    displayName: _displayName,
                    greeting: _greeting,
                    isLoading: _isLoadingUser,
                  ),
                ),

                // Health Score Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _HealthScoreCard(
                      score:      _healthScore,
                      label:      _healthScoreLabel,
                      labelColor: _healthScoreColor,
                      diagCount:  _diagnosisCount,
                      smartPts:   _smartPts,
                      isLoading:  _isLoadingUser,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Smart Points Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HalocoinsCard(points: _smartPts),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Menu Grid
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Layanan Kesehatan',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      const SizedBox(height: 16),
                      const MenuGrid(),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Promo Banner
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Promo Spesial',
                                style: Theme.of(context).textTheme.headlineMedium),
                            GestureDetector(
                              onTap: () {},
                              child: const Text('Lihat Semua',
                                  style: TextStyle(color: AppTheme.primaryTeal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13, fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const PromoBanner(),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Artikel Kesehatan
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Artikel Kesehatan',
                                style: Theme.of(context).textTheme.headlineMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppTheme.primaryTeal, width: 1.5),
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text('Lihat Semua',
                                  style: TextStyle(color: AppTheme.primaryTeal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12, fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ArticleSection(),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 120),
                ),
              ],
            ),
          ),

          // ── Scroll-aware app bar ─────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _headerOpacity,
              child: Container(
                height: MediaQuery.of(context).padding.top + 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12)],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      const Icon(Icons.health_and_safety_rounded,
                          color: AppTheme.primaryTeal, size: 26),
                      const SizedBox(width: 8),
                      const Text('Smart Health',
                          style: TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 16, color: AppTheme.textPrimary,
                              fontFamily: 'Poppins')),
                      const Spacer(),
                      // Notif icon di collapsed state
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: AppTheme.textSecondary, size: 18),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// HEALTH SCORE CARD
// ══════════════════════════════════════════════════════════════════

class _HealthScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final Color labelColor;
  final int diagCount;
  final int smartPts;
  final bool isLoading;

  const _HealthScoreCard({
    required this.score,
    required this.label,
    required this.labelColor,
    required this.diagCount,
    required this.smartPts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: AppTheme.navyGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.elevatedShadow),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, color: AppTheme.primaryTeal, size: 8),
                SizedBox(width: 6),
                Text('AI Health Monitor',
                    style: TextStyle(color: AppTheme.primaryTeal,
                        fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 0.5, fontFamily: 'Poppins')),
              ]),
            ),
            const SizedBox(height: 12),

            const Text('Skor Kesehatan\nUrbanmu',
                style: TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.w700, height: 1.3,
                    letterSpacing: -0.3, fontFamily: 'Poppins')),
            const SizedBox(height: 8),

            // Status label
            isLoading
                ? Container(
                    width: 100, height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7)))
                : Text(score == 0 ? 'Mulai cek kesehatan kamu!' : label,
                    style: TextStyle(color: labelColor,
                        fontSize: 12, fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),

            const SizedBox(height: 14),

            // Mini stats
            Row(children: [
              _miniStat(Icons.biotech_rounded, '$diagCount Diagnosis',
                  AppTheme.primaryTeal),
              const SizedBox(width: 14),
              _miniStat(Icons.stars_rounded, '$smartPts Pts',
                  AppTheme.accentOrange),
            ]),
          ],
        )),

        const SizedBox(width: 16),

        // Score circle
        isLoading
            ? _loadingCircle()
            : _ScoreCircle(score: score),
      ]),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7),
          fontSize: 11, fontFamily: 'Poppins')),
    ],
  );

  Widget _loadingCircle() => SizedBox(
    width: 90, height: 90,
    child: CircularProgressIndicator(
        strokeWidth: 8,
        backgroundColor: Colors.white.withOpacity(0.1),
        color: AppTheme.primaryTeal),
  );
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 90, height: 90,
        child: CircularProgressIndicator(
          value: score == 0 ? 0 : score / 100,
          strokeWidth: 8,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
              score >= 80 ? AppTheme.primaryTeal
              : score >= 60 ? AppTheme.warning
              : AppTheme.danger),
          strokeCap: StrokeCap.round,
        ),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(score == 0 ? '-' : '$score',
            style: const TextStyle(color: Colors.white, fontSize: 26,
                fontWeight: FontWeight.w800, height: 1, fontFamily: 'Poppins')),
        if (score > 0)
          const Text('pts', style: TextStyle(color: AppTheme.primaryTeal,
              fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      ]),
    ]);
  }
}



// // KODE BARU 20-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/home/header.dart';
// import '../../widgets/home/halocoins_card.dart';
// import '../../widgets/home/menu_grid.dart';
// import '../../widgets/home/promo_banner.dart';
// import '../../widgets/home/article_section.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();
//   double _headerOpacity = 0;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(() {
//       final offset = _scrollController.offset;
//       setState(() {
//         _headerOpacity = (offset / 100).clamp(0.0, 1.0);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.bgLight,
//       body: Stack(
//         children: [
//           // Scrollable content
//           CustomScrollView(
//             controller: _scrollController,
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // Hero Header
//               SliverToBoxAdapter(child: HomeHeader()),

//               // Health Score Card
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//                   child: _HealthScoreCard(),
//                 ),
//               ),

//               const SliverToBoxAdapter(child: SizedBox(height: 24)),

//               // Coins Card
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: const HalocoinsCard(),
//                 ),
//               ),

//               const SliverToBoxAdapter(child: SizedBox(height: 28)),

//               // Menu Grid
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Text(
//                         'Layanan Kesehatan',
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const MenuGrid(),
//                   ],
//                 ),
//               ),

//               const SliverToBoxAdapter(child: SizedBox(height: 28)),

//               // Promo Banner
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Promo Spesial',
//                             style: Theme.of(context).textTheme.headlineMedium,
//                           ),
//                           TextButton(
//                             onPressed: () {},
//                             child: const Text(
//                               'Lihat Semua',
//                               style: TextStyle(
//                                 color: AppTheme.primaryTeal,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const PromoBanner(),
//                   ],
//                 ),
//               ),

//               const SliverToBoxAdapter(child: SizedBox(height: 28)),

//               // Articles
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Artikel Kesehatan',
//                             style: Theme.of(context).textTheme.headlineMedium,
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: AppTheme.primaryTeal,
//                                 width: 1.5,
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Text(
//                               'Lihat Semua',
//                               style: TextStyle(
//                                 color: AppTheme.primaryTeal,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const ArticleSection(),
//                   ],
//                 ),
//               ),

//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height: MediaQuery.of(context).padding.bottom + 120,
//                 ),
//               ),
//             ],
//           ),

//           // Scroll-aware app bar overlay
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 200),
//               opacity: _headerOpacity,
//               child: Container(
//                 height: MediaQuery.of(context).padding.top + 56,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 12,
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           'assets/images/logo.png',
//                           height: 32,
//                           errorBuilder: (_, __, ___) => const Row(
//                             children: [
//                               Icon(
//                                 Icons.health_and_safety_rounded,
//                                 color: AppTheme.primaryTeal,
//                                 size: 28,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Smart Health',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 16,
//                                   color: AppTheme.textPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HealthScoreCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: AppTheme.navyGradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: AppTheme.elevatedShadow,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryTeal.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.circle, color: AppTheme.primaryTeal, size: 8),
//                       SizedBox(width: 6),
//                       Text(
//                         'AI Health Monitor',
//                         style: TextStyle(
//                           color: AppTheme.primaryTeal,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Skor Kesehatan\nUrbanmu Hari Ini',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     height: 1.3,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryTeal,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Text(
//                         'Cek Sekarang →',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           _ScoreCircle(score: 82),
//         ],
//       ),
//     );
//   }
// }

// class _ScoreCircle extends StatelessWidget {
//   final int score;
//   const _ScoreCircle({required this.score});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         SizedBox(
//           width: 90,
//           height: 90,
//           child: CircularProgressIndicator(
//             value: score / 100,
//             strokeWidth: 8,
//             backgroundColor: Colors.white.withOpacity(0.1),
//             valueColor: const AlwaysStoppedAnimation<Color>(
//               AppTheme.primaryTeal,
//             ),
//             strokeCap: StrokeCap.round,
//           ),
//         ),
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '$score',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.w800,
//                 height: 1,
//               ),
//             ),
//             const Text(
//               'pts',
//               style: TextStyle(
//                 color: AppTheme.primaryTeal,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }