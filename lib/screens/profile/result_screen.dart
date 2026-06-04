import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ResultScreen extends StatelessWidget {
  final DiagnosisResult result;
  const ResultScreen({super.key, required this.result});

  Color get _urgencyColor {
    switch (result.urgency.level.toLowerCase()) {
      case 'urgent':
        return AppTheme.danger;
      case 'semi':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = result.topPrediction;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.primaryNavy,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            title: const Text(
              'Hasil Prediksi AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Main result card ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.navyGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        // Confidence circle
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: result.urgency.confidence,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.primaryTeal,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${result.confidencePercent}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Text(
                                    'Akurasi',
                                    style: TextStyle(
                                      color: AppTheme.primaryTeal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          '${result.urgency.emoji} Prediksi Utama',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          top?.disease ?? result.topDisease,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Urgency badge (prevent overflow by ellipsizing long text)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _urgencyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _urgencyColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: _urgencyColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${result.urgency.label} — ${result.urgency.action}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: _urgencyColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Top 3 Predictions ──
                  if (result.predictions.length > 1) ...[
                    _SectionCard(
                      title: 'Top 3 Kemungkinan Penyakit',
                      icon: Icons.list_alt_rounded,
                      color: AppTheme.primaryTeal,
                      child: Column(
                        children: result.predictions
                            .map((p) => _PredictionTile(p: p))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Description ──
                  if (top != null && top.description.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Tentang ${top.disease}',
                      icon: Icons.info_rounded,
                      color: AppTheme.accentBlue,
                      child: Text(
                        top.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins',
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Precautions / Rekomendasi ──
                  if (top != null && top.precautions.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Rekomendasi',
                      icon: Icons.medical_services_rounded,
                      color: AppTheme.primaryTeal,
                      child: Column(
                        children: top.precautions
                            .map(
                              (p) => _BulletItem(
                                text: p,
                                color: AppTheme.primaryTeal,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Lifestyle Recommendation ──
                  if (result.lifestyleRecommendation.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Rekomendasi Gaya Hidup',
                      icon: Icons.spa_rounded,
                      color: AppTheme.success,
                      child: Column(
                        children: result.lifestyleRecommendation
                            .map(
                              (r) =>
                                  _BulletItem(text: r, color: AppTheme.success),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Urgency detail ──
                  if (result.urgency.description.isNotEmpty)
                    _SectionCard(
                      title: 'Tingkat Urgensi',
                      icon: Icons.warning_rounded,
                      color: _urgencyColor,
                      child: Text(
                        result.urgency.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins',
                          height: 1.6,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Action buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Ulangi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            side: const BorderSide(
                              color: AppTheme.primaryTeal,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text('Konsultasi Dokter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _PredictionTile extends StatelessWidget {
  final DiseasePrediction p;
  const _PredictionTile({required this.p});

  @override
  Widget build(BuildContext context) {
    final pct = (p.probabilityRf * 100).round();
    final colors = [AppTheme.primaryTeal, AppTheme.warning, AppTheme.textMuted];
    final color = colors[(p.rank - 1).clamp(0, 2)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${p.rank}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.disease,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.probabilityRf,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}


// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';
// import '../../services/api_service.dart';

// class ResultScreen extends StatelessWidget {
//   final DiagnosisResult result;
//   const ResultScreen({super.key, required this.result});

//   Color get _urgencyColor {
//     switch (result.urgency.level.toLowerCase()) {
//       case 'urgent':
//         return Colors.redAccent;
//       case 'semi':
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   String get _urgencyText {
//     switch (result.urgency.level.toLowerCase()) {
//       case 'urgent':
//         return 'DARURAT';
//       case 'semi':
//         return 'PERHATIAN';
//       default:
//         return 'NORMAL';
//     }
//   }

//   double get _urgencyValue {
//     switch (result.urgency.level.toLowerCase()) {
//       case 'urgent':
//         return 1;
//       case 'semi':
//         return 0.6;
//       default:
//         return 0.3;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final top = result.topPrediction;

//     return Scaffold(
//       backgroundColor: AppTheme.bgLight,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [

//               // 🔥 HEADER
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.arrow_back),
//                   ),
//                   const Text(
//                     "Hasil Diagnosis AI",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // 🔥 MAIN CARD
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.navyGradient,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: AppTheme.elevatedShadow,
//                 ),
//                 child: Column(
//                   children: [

//                     // 🔥 CIRCLE
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 130,
//                           height: 130,
//                           child: CircularProgressIndicator(
//                             value: _urgencyValue,
//                             strokeWidth: 10,
//                             valueColor: AlwaysStoppedAnimation(_urgencyColor),
//                             backgroundColor: Colors.white12,
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             Text(
//                               _urgencyText,
//                               style: TextStyle(
//                                 color: _urgencyColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(
//                               "${result.confidencePercent}%",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           ],
//                         )
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     Text(
//                       top?.disease ?? result.topDisease,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     // 🔥 BADGE FIX (NO OVERFLOW)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: _urgencyColor.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         result.urgency.label,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: _urgencyColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // 🔥 TOP 3
//               if (result.predictions.isNotEmpty)
//                 _card(
//                   "Top Prediksi",
//                   Column(
//                     children: result.predictions.map((p) {
//                       final pct = (p.probabilityRf * 100).round();
//                       return Column(
//                         children: [
//                           Row(
//                             children: [
//                               Text(p.disease),
//                               const Spacer(),
//                               Text("$pct%"),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           LinearProgressIndicator(
//                             value: p.probabilityRf,
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),

//               const SizedBox(height: 16),

//               // 🔥 URGENCY DESC
//               _card(
//                 "Tingkat Urgensi",
//                 Text(result.urgency.description),
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _card(String title, Widget child) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: AppTheme.cardShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 15)),
//           const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     );
//   }
// }