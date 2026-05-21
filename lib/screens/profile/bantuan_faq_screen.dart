import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BantuanFaqScreen extends StatefulWidget {
  const BantuanFaqScreen({super.key});

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  final _searchCtrl = TextEditingController();
  int? _expandedIndex;
  String _query = '';

  static const List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.biotech_rounded,
      'label': 'Diagnosis',
      'color': Color(0xFF00D4AA),
    },
    {
      'icon': Icons.medical_services_rounded,
      'label': 'Konsultasi',
      'color': Color(0xFF667EEA),
    },
    {
      'icon': Icons.account_circle_outlined,
      'label': 'Akun',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'label': 'ChatBOT',
      'color': Color(0xFF22C55E),
    },
  ];

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara melakukan diagnosis pada aplikasi? ',
      'a': 'Kamu bisa melakukan diagnosis dengan menekan tombol yang ada di bagian tengah bawah aplikasi. Masukan data atau informasi penyakit kamu, lalu tunggu hasil analisis dari AI kami dalam beberapa detik.',
    },
    {
      'q': 'Apakah diagnosis dari Aplikasi Kami akurat?',
      'a': 'PuskesmasKu menggunakan teknologi AI berbasis Machine Learning telah dilatih dengan beberapa dataset. Tingkat akurasi kami mencapai 85-90%, namun hasil diagnosis ini bersifat indikatif atau bisa dibilang sebagai sistem pendukung keputusan untuk diagnosis awal penyakit dan tetap disarankan untuk berkonsultasi dengan dokter langsung.',
    },
    {
      'q': 'Berapa biaya konsultasi?',
      'a': 'Biaya konsultasi yang kami sediakan relatif lebih murah. Mulai dari Rp 30.000 untuk konsultasi, Kamu juga bisa menggunakan Smart Points setiap kamu melakukan Konsultasi.',
    },
    {
      'q': 'Apa itu Smart Points?',
      'a': 'Smart Points adalah poin reward yang kamu kumpulkan dari setiap aktivitas di aplikasi PuskesmasKu, seperti melakukan diagnosis, konsultasi, dan menulis ulasan. Poin dapat ditukarkan dengan diskon layanan atau produk pada puskesmas.',
    },
    {
      'q': 'Bagaimana cara mengganti kata sandi?',
      'a': 'Buka halaman Profil → tekan tombol edit (ikon pensil) → pilih "Ganti Password". Masukkan kata sandi lama dan kata sandi baru minimal 6 karakter.',
    },
    {
      'q': 'Data saya apakah aman?',
      'a': 'Kami sangat menjaga privasi data kamu. Seluruh foto dan data diagnosis disimpan secara terenkripsi dan tidak akan dibagikan kepada pihak ketiga tanpa izin kamu. Baca Kebijakan Privasi kami untuk informasi lebih lengkap.',
    },
    {
      'q': 'Bagaimana cara menghapus akun saya?',
      'a': 'Untuk menghapus akun, silakan hubungi tim support kami melalui email bayuurokhmatullah@gmail.com. Proses penghapusan akun memerlukan waktu maksimal 2-3 hari kerja.',
    },
    {
      'q': 'Apakah PuskesmasKu tersedia untuk iOS?',
      'a': 'Saat ini PuskesmasKu tersedia untuk platform Android. Untuk Versi iOS akan kami percepat dalam pengembangan dan akan segera diluncurkan. Daftarkan email kamu untuk mendapat notifikasi peluncuran.',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_query.isEmpty) return _faqs;
    return _faqs.where((faq) =>
        faq['q']!.toLowerCase().contains(_query.toLowerCase()) ||
        faq['a']!.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bantuan & FAQ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() { _query = v; _expandedIndex = null; }),
              style: const TextStyle(fontSize: 13, fontFamily: 'Poppins',
                  color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted,
                    fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textMuted, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textMuted, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() { _query = ''; _expandedIndex = null; });
                        })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories
          if (_query.isEmpty) ...[
            const Text('TOPIK BANTUAN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted, letterSpacing: 0.9,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: _categories.map((cat) => _CategoryItem(
                icon: cat['icon'] as IconData,
                label: cat['label'] as String,
                color: cat['color'] as Color,
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // FAQ list
          Text(_query.isEmpty ? 'PERTANYAAN UMUM' : 'HASIL PENCARIAN',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted, letterSpacing: 0.9,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 12),

          if (_filteredFaqs.isEmpty)
            Center(
              child: Column(children: [
                const SizedBox(height: 32),
                const Icon(Icons.search_off_rounded,
                    color: AppTheme.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('Tidak ada hasil untuk "$_query"',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted,
                        fontFamily: 'Poppins')),
              ]),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: _filteredFaqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  final isLast = i == _filteredFaqs.length - 1;
                  final isExpanded = _expandedIndex == i;
                  return Column(children: [
                    _FaqItem(
                      question: faq['q']!,
                      answer: faq['a']!,
                      isExpanded: isExpanded,
                      onTap: () => setState(() =>
                          _expandedIndex = isExpanded ? null : i),
                    ),
                    if (!isLast)
                      Divider(height: 1, indent: 16,
                          endIndent: 16, color: AppTheme.divider),
                  ]);
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // Contact Support
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Column(children: [
              const Icon(Icons.support_agent_rounded,
                  color: Color.fromARGB(255, 240, 251, 248), size: 32),
              const SizedBox(height: 10),
              const Text('Masih butuh bantuan?',
                  style: TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Text('Tim support kami siap membantu 24/7',
                  style: TextStyle(color: Colors.white.withOpacity(0.6),
                      fontSize: 12, fontFamily: 'Poppins')),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _contactButton(
                    Icons.chat_bubble_outline_rounded, 'Live Chat',
                    AppTheme.primaryTeal)),
                const SizedBox(width: 10),
                Expanded(child: _contactButton(
                    Icons.email_outlined, 'Email',
                    const Color(0xFF667EEA))),
              ]),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _contactButton(IconData icon, String label, Color color) =>
      GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12,
                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ]),
        ),
      );
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryItem({required this.icon, required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10,
            fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
            fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question, answer;
  final bool isExpanded;
  final VoidCallback onTap;
  const _FaqItem({required this.question, required this.answer,
      required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppTheme.primaryTeal.withOpacity(0.1)
                    : AppTheme.bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                size: 14,
                color: isExpanded ? AppTheme.primaryTeal : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(question,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: isExpanded
                          ? AppTheme.primaryTeal : AppTheme.textPrimary)),
            ),
          ]),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(answer,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary,
                      fontFamily: 'Poppins', height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}