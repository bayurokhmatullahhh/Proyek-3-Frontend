// KODE BARU 20-04-2026

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  static const List<_EduCategory> _categories = [
    _EduCategory(label: 'Semua', isActive: true),
    _EduCategory(label: 'Hipertensi'),
    _EduCategory(label: 'Diabetes'),
    _EduCategory(label: 'Jantung'),
    _EduCategory(label: 'Nutrisi'),
    _EduCategory(label: 'Mental'),
  ];

  static const List<_EduItem> _featured = [
    _EduItem(
      title: 'Mengenal Faktor Risiko\nPenyakit Urban',
      category: 'Penyakit Kota',
      duration: '8 menit baca',
      gradient: AppTheme.navyGradient,
      icon: Icons.location_city_rounded,
    ),
    _EduItem(
      title: 'Cara Kelola Stres di\nLingkungan Kerja',
      category: 'Mental Health',
      duration: '5 menit baca',
      gradient: LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.psychology_rounded,
    ),
  ];

  static const List<_VideoItem> _videos = [
    _VideoItem(
      title: 'Kenali Gejala Hipertensi',
      duration: '4:32',
      views: '12.4K',
      color: Color(0xFFEF4444),
    ),
    _VideoItem(
      title: 'Olahraga Ringan untuk Pekerja',
      duration: '6:15',
      views: '8.7K',
      color: Color(0xFF00D4AA),
    ),
    _VideoItem(
      title: 'Pola Makan Sehat Sehari-hari',
      duration: '5:48',
      views: '15.2K',
      color: Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: const Text(
              'Edukasi Kesehatan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary, size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: cat.isActive ? AppTheme.primaryGradient : null,
                          color: cat.isActive ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cat.isActive
                                ? Colors.transparent
                                : AppTheme.divider,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cat.isActive
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Featured Articles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Artikel Pilihan',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _featured.length,
                    itemBuilder: (context, index) =>
                        _FeaturedCard(item: _featured[index]),
                  ),
                ),

                const SizedBox(height: 28),

                // Video Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Video Edukasi',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _videos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _VideoCard(item: _videos[index]),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final _EduItem item;
  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.elevatedShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 12, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                item.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Baca →',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _VideoCard extends StatelessWidget {
  final _VideoItem item;
  const _VideoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 60,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.play_circle_outline_rounded,
                        size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${item.views} views',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined,
                        size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      item.duration,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}

class _EduCategory {
  final String label;
  final bool isActive;
  const _EduCategory({required this.label, this.isActive = false});
}

class _EduItem {
  final String title;
  final String category;
  final String duration;
  final LinearGradient gradient;
  final IconData icon;
  const _EduItem({
    required this.title,
    required this.category,
    required this.duration,
    required this.gradient,
    required this.icon,
  });
}

class _VideoItem {
  final String title;
  final String duration;
  final String views;
  final Color color;
  const _VideoItem({
    required this.title,
    required this.duration,
    required this.views,
    required this.color,
  });
}

// import 'package:flutter/material.dart';

// class EdukasiScreen extends StatelessWidget {
//   const EdukasiScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edukasi Kesehatan"),
//         backgroundColor: const Color(0xFF2EC4B6),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: const [
//           EduCard(
//             title: "Tips Pola Hidup Sehat",
//             subtitle: "Cara menjaga kesehatan tubuh setiap hari",
//             icon: Icons.favorite,
//           ),
//           EduCard(
//             title: "Bahaya Asam Lambung",
//             subtitle: "Kenali gejala GERD sejak dini",
//             icon: Icons.warning,
//           ),
//           EduCard(
//             title: "Menjaga Kesehatan Jantung",
//             subtitle: "Pola makan & olahraga yang tepat",
//             icon: Icons.monitor_heart,
//           ),
//           EduCard(
//             title: "Cara Mengatasi Stres",
//             subtitle: "Tips kesehatan mental",
//             icon: Icons.psychology,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class EduCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;

//   const EduCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: const BoxDecoration(
//               color: Color(0xFF2EC4B6),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 5),
//                 Text(subtitle, style: const TextStyle(color: Colors.grey)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }