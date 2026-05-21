
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArticleSection extends StatefulWidget {
  const ArticleSection({super.key});

  @override
  State<ArticleSection> createState() => _ArticleSectionState();
}

class _ArticleSectionState extends State<ArticleSection> {
  String _activeFilter = 'Semua';

  // Data artikel — nanti dari GET /api/articles (admin bisa tambah di Laravel)
  static const List<_Article> _articles = [
    _Article(
      id: '1',
      tag: 'Hipertensi',
      title: 'Bahaya Tekanan Darah Tinggi bagi Warga Urban',
      summary: 'Hipertensi adalah pembunuh senyap yang sering tidak disadari. '
          'Pelajari gejala, penyebab, dan cara pencegahan yang efektif.',
      readTime: '5 menit',
      date: '24 Apr 2026',
      color: Color(0xFFEF4444),
      icon: Icons.favorite_rounded,
      content: 'Hipertensi atau tekanan darah tinggi adalah kondisi di mana '
          'tekanan darah dalam arteri terus-menerus meningkat. Bagi warga '
          'perkotaan, risiko hipertensi lebih tinggi akibat stres pekerjaan, '
          'pola makan tidak sehat, dan kurangnya aktivitas fisik.\n\n'
          'Gejala umum hipertensi meliputi sakit kepala, pusing, sesak napas, '
          'dan nyeri dada. Namun, banyak penderita tidak merasakan gejala '
          'apapun hingga kondisi menjadi parah.\n\n'
          'Pencegahan dapat dilakukan dengan rutin berolahraga, mengurangi '
          'konsumsi garam, tidak merokok, dan mengelola stres dengan baik.',
    ),
    _Article(
      id: '2',
      tag: 'Diabetes',
      title: 'Gaya Hidup Sehat untuk Cegah Diabetes Tipe 2',
      summary: 'Perubahan gaya hidup sederhana dapat menurunkan risiko '
          'diabetes tipe 2 hingga 58%. Simak panduan lengkapnya.',
      readTime: '4 menit',
      date: '22 Apr 2026',
      color: Color(0xFFF59E0B),
      icon: Icons.water_drop_rounded,
      content: 'Diabetes tipe 2 adalah kondisi di mana tubuh tidak dapat '
          'menggunakan insulin secara efektif. Penyakit ini sangat erat '
          'kaitannya dengan gaya hidup, terutama pola makan dan aktivitas '
          'fisik yang kurang.\n\n'
          'Langkah pencegahan yang terbukti efektif:\n'
          '• Jaga berat badan ideal\n'
          '• Olahraga minimal 30 menit per hari\n'
          '• Kurangi konsumsi gula dan karbohidrat sederhana\n'
          '• Perbanyak sayuran dan serat\n'
          '• Rutin cek gula darah\n\n'
          'Dengan perubahan gaya hidup, risiko diabetes dapat ditekan '
          'secara signifikan bahkan bagi mereka yang memiliki riwayat keluarga.',
    ),
    _Article(
      id: '3',
      tag: 'Mental',
      title: 'Stres Kerja: Kenali Tanda & Cara Mengatasinya',
      summary: 'Burnout dan stres kerja adalah epidemi modern. '
          'Kenali tandanya sebelum berdampak pada kesehatan fisik.',
      readTime: '6 menit',
      date: '20 Apr 2026',
      color: Color(0xFF8B5CF6),
      icon: Icons.psychology_rounded,
      content: 'Stres kerja yang berkepanjangan dapat menyebabkan burnout — '
          'kondisi kelelahan fisik dan mental yang serius. Di era urban modern, '
          'ini menjadi salah satu masalah kesehatan terbesar.\n\n'
          'Tanda-tanda burnout:\n'
          '• Kelelahan ekstrem meski sudah istirahat\n'
          '• Sulit berkonsentrasi\n'
          '• Mudah marah atau menangis\n'
          '• Kehilangan motivasi kerja\n'
          '• Keluhan fisik seperti sakit kepala dan insomnia\n\n'
          'Cara mengatasinya:\n'
          '• Tetapkan batasan antara kerja dan istirahat\n'
          '• Olahraga teratur\n'
          '• Meditasi atau mindfulness\n'
          '• Konsultasi dengan psikolog jika diperlukan',
    ),
    _Article(
      id: '4',
      tag: 'Nutrisi',
      title: 'Panduan Makan Sehat untuk Pekerja Kantoran',
      summary: 'Sibuk bekerja bukan alasan makan sembarangan. '
          'Ikuti panduan praktis ini untuk tetap sehat di kantor.',
      readTime: '3 menit',
      date: '18 Apr 2026',
      color: Color(0xFF22C55E),
      icon: Icons.restaurant_rounded,
      content: 'Pola makan pekerja kantoran sering kali buruk — terlalu '
          'banyak makanan cepat saji, makan tidak teratur, dan kurang sayuran. '
          'Padahal nutrisi sangat mempengaruhi produktivitas kerja.\n\n'
          'Tips makan sehat di kantor:\n'
          '• Sarapan setiap hari — jangan dilewatkan\n'
          '• Bawa bekal dari rumah\n'
          '• Simpan camilan sehat (buah, kacang) di laci\n'
          '• Minum air putih minimal 8 gelas\n'
          '• Hindari minuman manis dan soda\n'
          '• Makan siang dengan porsi yang tepat\n\n'
          'Perubahan kecil ini dapat meningkatkan energi, konsentrasi, '
          'dan kesehatan jangka panjang.',
    ),
    _Article(
      id: '5',
      tag: 'Olahraga',
      title: 'Olahraga 30 Menit yang Bisa Dilakukan di Kantor',
      summary: 'Tidak punya waktu ke gym? Coba gerakan sederhana '
          'yang bisa dilakukan di antara jam kerja.',
      readTime: '4 menit',
      date: '15 Apr 2026',
      color: Color(0xFF3A7BD5),
      icon: Icons.fitness_center_rounded,
      content: 'Kurang gerak adalah masalah utama pekerja kantoran. '
          'Duduk lebih dari 8 jam sehari dapat meningkatkan risiko berbagai '
          'penyakit kronis.\n\n'
          'Gerakan yang bisa dilakukan di kantor:\n'
          '• Peregangan leher dan bahu setiap 1 jam\n'
          '• Berjalan ke toilet yang lebih jauh\n'
          '• Gunakan tangga, bukan lift\n'
          '• Squat atau jumping jack di ruang kosong\n'
          '• Berdiri saat meeting atau telepon\n\n'
          'Target minimal 30 menit aktivitas fisik per hari, '
          'meski dilakukan bertahap 5-10 menit.',
    ),
    _Article(
      id: '6',
      tag: 'Hipertensi',
      title: 'Makanan yang Membantu Turunkan Tekanan Darah',
      summary: 'Beberapa jenis makanan terbukti secara ilmiah '
          'dapat membantu menurunkan tekanan darah secara alami.',
      readTime: '4 menit',
      date: '12 Apr 2026',
      color: Color(0xFFEF4444),
      icon: Icons.favorite_rounded,
      content: 'Diet DASH (Dietary Approaches to Stop Hypertension) '
          'adalah pola makan yang terbukti menurunkan tekanan darah.\n\n'
          'Makanan yang dianjurkan:\n'
          '• Pisang — kaya kalium\n'
          '• Bit — mengandung nitrat alami\n'
          '• Bawang putih — menurunkan kekakuan arteri\n'
          '• Cokelat hitam — flavonoid melancarkan sirkulasi\n'
          '• Bayam dan sayuran hijau\n'
          '• Ikan berlemak seperti salmon\n\n'
          'Kombinasikan dengan gaya hidup sehat dan konsultasi '
          'dokter untuk hasil optimal.',
    ),
  ];

  static const List<String> _filters = [
    'Semua', 'Hipertensi', 'Diabetes', 'Mental', 'Nutrisi', 'Olahraga',
  ];

  List<_Article> get _filtered {
    if (_activeFilter == 'Semua') return _articles;
    return _articles.where((a) => a.tag == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Filter chips
      SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          itemBuilder: (_, i) {
            final f = _filters[i];
            final active = f == _activeFilter;
            return GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: active ? AppTheme.primaryGradient : null,
                  color: active ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? Colors.transparent : AppTheme.divider,
                      width: 1.5),
                  boxShadow: active ? AppTheme.tealGlow : null,
                ),
                alignment: Alignment.center,
                child: Text(f,
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: active ? Colors.white : AppTheme.textSecondary)),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 14),

      // Article list
      if (_filtered.isEmpty)
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            Icon(Icons.article_outlined, size: 48,
                color: AppTheme.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Belum ada artikel untuk "$_activeFilter"',
                style: const TextStyle(color: AppTheme.textMuted,
                    fontSize: 13, fontFamily: 'Poppins'),
                textAlign: TextAlign.center),
          ]),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ArticleCard(
            article: _filtered[i],
            onTap: () => _openArticle(context, _filtered[i]),
          ),
        ),
    ]);
  }

  void _openArticle(BuildContext context, _Article article) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _ArticleDetailScreen(article: article),
    ));
  }
}

// ── Article Card ──────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;
  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow),
        child: Row(children: [
          // Icon
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: article.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(article.icon, color: article.color, size: 26)),
          const SizedBox(width: 14),
          // Content
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: article.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(article.tag,
                      style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: article.color, fontFamily: 'Poppins',
                          letterSpacing: 0.3)),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Text(article.readTime,
                    style: const TextStyle(fontSize: 10,
                        color: AppTheme.textMuted, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 8),
              Text(article.title,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins', height: 1.35),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text(article.summary,
                  style: const TextStyle(fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Poppins', height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppTheme.textMuted),
        ]),
      ),
    );
  }
}

// ── Article Detail Screen ─────────────────────────────────────────────

class _ArticleDetailScreen extends StatelessWidget {
  final _Article article;
  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: article.color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20)),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.bookmark_border_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [article.color, article.color.withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(right: -40, top: -40, child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08)))),
                  SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(article.tag,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins', letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 10),
                        Text(article.title,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 20, fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins', height: 1.3)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Icon(Icons.access_time_rounded,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(article.readTime,
                              style: const TextStyle(color: Colors.white70,
                                  fontSize: 12, fontFamily: 'Poppins')),
                          const SizedBox(width: 14),
                          Icon(Icons.calendar_today_rounded,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(article.date,
                              style: const TextStyle(color: Colors.white70,
                                  fontSize: 12, fontFamily: 'Poppins')),
                        ]),
                      ],
                    ),
                  )),
                ]),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: article.color.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: article.color.withOpacity(0.2))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Icon(Icons.format_quote_rounded,
                          color: article.color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(article.summary,
                          style: TextStyle(fontSize: 13,
                              color: article.color,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 1.5))),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Full content
                  Text('Isi Artikel', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  Text(article.content,
                      style: const TextStyle(fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins', height: 1.7)),
                  const SizedBox(height: 24),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.info.withOpacity(0.2))),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppTheme.info, size: 16),
                      SizedBox(width: 8),
                      Expanded(child: Text(
                          'Artikel ini bersifat informatif. Selalu konsultasikan '
                          'kondisi kesehatan kamu dengan tenaga medis.',
                          style: TextStyle(fontSize: 11, color: AppTheme.info,
                              fontFamily: 'Poppins', height: 1.5))),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Related articles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Artikel Terkait', style: Theme.of(context)
                    .textTheme.headlineMedium),
                const SizedBox(height: 12),
                ..._ArticleSectionState._articles
                    .where((a) => a.id != article.id && a.tag == article.tag)
                    .take(2)
                    .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ArticleCard(
                        article: a,
                        onTap: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(
                              builder: (_) => _ArticleDetailScreen(article: a))),
                      ),
                    )),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────

class _Article {
  final String id, tag, title, summary, readTime, date, content;
  final Color color;
  final IconData icon;
  const _Article({
    required this.id, required this.tag, required this.title,
    required this.summary, required this.readTime, required this.date,
    required this.color, required this.icon, required this.content,
  });
}


// // KODE BARU 20-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class ArticleSection extends StatelessWidget {
//   const ArticleSection({super.key});

//   static const List<_Article> _articles = [
//     _Article(
//       tag: 'Hipertensi',
//       title: 'Bahaya Tekanan Darah Tinggi bagi Warga Urban',
//       readTime: '5 menit',
//       color: Color(0xFFEF4444),
//       icon: Icons.favorite_rounded,
//     ),
//     _Article(
//       tag: 'Diabetes',
//       title: 'Gaya Hidup Sehat Cegah Diabetes Tipe 2',
//       readTime: '4 menit',
//       color: Color(0xFFF59E0B),
//       icon: Icons.water_drop_rounded,
//     ),
//     _Article(
//       tag: 'Mental',
//       title: 'Stres Kerja: Kenali Tanda & Cara Mengatasinya',
//       readTime: '6 menit',
//       color: Color(0xFF8B5CF6),
//       icon: Icons.psychology_rounded,
//     ),
//     _Article(
//       tag: 'Nutrisi',
//       title: 'Panduan Makan Sehat Untuk Pekerja Kantoran',
//       readTime: '3 menit',
//       color: Color(0xFF22C55E),
//       icon: Icons.restaurant_rounded,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Filter chips
//         SizedBox(
//           height: 38,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             children: const [
//               _FilterChip(label: 'Semua', isActive: true),
//               _FilterChip(label: 'Hipertensi'),
//               _FilterChip(label: 'Diabetes'),
//               _FilterChip(label: 'Mental Health'),
//               _FilterChip(label: 'Nutrisi'),
//               _FilterChip(label: 'Olahraga'),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Articles list
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           itemCount: _articles.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (context, index) =>
//               _ArticleCard(article: _articles[index]),
//         ),
//       ],
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   const _FilterChip({required this.label, this.isActive = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         gradient: isActive ? AppTheme.primaryGradient : null,
//         color: isActive ? null : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isActive ? Colors.transparent : AppTheme.divider,
//           width: 1.5,
//         ),
//         boxShadow: isActive ? AppTheme.tealGlow : null,
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: isActive ? Colors.white : AppTheme.textSecondary,
//         ),
//       ),
//     );
//   }
// }

// class _ArticleCard extends StatelessWidget {
//   final _Article article;
//   const _ArticleCard({required this.article});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: AppTheme.cardShadow,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: article.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(article.icon, color: article.color, size: 28),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: article.color.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         article.tag,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: article.color,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(Icons.access_time_rounded,
//                         size: 11, color: AppTheme.textMuted),
//                     const SizedBox(width: 3),
//                     Text(
//                       article.readTime,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: AppTheme.textMuted,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   article.title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.textPrimary,
//                     height: 1.4,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Icon(Icons.arrow_forward_ios_rounded,
//               size: 14, color: AppTheme.textMuted),
//         ],
//       ),
//     );
//   }
// }

// class _Article {
//   final String tag;
//   final String title;
//   final String readTime;
//   final Color color;
//   final IconData icon;
//   const _Article({
//     required this.tag,
//     required this.title,
//     required this.readTime,
//     required this.color,
//     required this.icon,
//   });
// }

