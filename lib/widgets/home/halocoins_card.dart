import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HalocoinsCard extends StatelessWidget {
  final int points;
  const HalocoinsCard({super.key, this.points = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPointsSheet(context),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          ),
          border: Border.all(color: const Color(0xFFFFD9A8), width: 1.5),
          boxShadow: [BoxShadow(
              color: AppTheme.accentOrange.withOpacity(0.15),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          // Coin icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: AppTheme.accentOrange.withOpacity(0.4),
                  blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.stars_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Smart Points',
                  style: TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 14, color: Color(0xFFB45309),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              RichText(text: TextSpan(
                style: const TextStyle(fontFamily: 'Poppins'),
                children: [
                  TextSpan(
                    text: '$points',
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309)),
                  ),
                  const TextSpan(
                    text: ' poin terkumpul — tap untuk detail',
                    style: TextStyle(fontSize: 10,
                        color: Color(0xFFB45309), fontWeight: FontWeight.w400),
                  ),
                ],
              )),
            ],
          )),
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: AppTheme.accentOrange, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 16),
          ),
        ]),
      ),
    );
  }

  void _showPointsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // Coin visual
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.4),
                    blurRadius: 20, spreadRadius: 4)]),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text('$points Smart Points',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309), fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          const Text('Kamu mendapatkan poin dari setiap aktivitas kesehatan',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted,
                  fontFamily: 'Poppins'),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // Cara dapat poin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD9A8))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Cara Mendapatkan Poin', style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13,
                  color: Color(0xFFB45309), fontFamily: 'Poppins')),
              const SizedBox(height: 10),
              ...[
                ('Diagnosis AI', '+10 poin', Icons.biotech_rounded),
                ('Login harian', '+2 poin',  Icons.login_rounded),
                ('Baca artikel', '+1 poin',  Icons.article_rounded),
              ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(e.$3, color: AppTheme.accentOrange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.$1, style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary,
                      fontFamily: 'Poppins'))),
                  Text(e.$2, style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700, color: Color(0xFFB45309),
                      fontFamily: 'Poppins')),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}



// // KODE BARU 20-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class HalocoinsCard extends StatelessWidget {
//   const HalocoinsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 72,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
//         ),
//         border: Border.all(color: const Color(0xFFFFD9A8), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.accentOrange.withOpacity(0.12),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 16),
//           // Coin icon
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: AppTheme.accentOrange.withOpacity(0.4),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.stars_rounded,
//               color: Colors.white,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Smart Points',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     color: Color(0xFFB45309),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Kumpulkan & tukarkan poin kesehatanmu!',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: const Color(0xFFB45309).withOpacity(0.7),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(right: 14),
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: AppTheme.accentOrange,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_forward_rounded,
//               color: Colors.white,
//               size: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
