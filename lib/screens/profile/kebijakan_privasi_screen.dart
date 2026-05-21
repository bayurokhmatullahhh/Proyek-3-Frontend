import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  static const List<Map<String, dynamic>> _sections = [
    {
      'icon': Icons.info_outline_rounded,
      'title': '1. Informasi yang Kami Kumpulkan',
      'content':
          'Kami mengumpulkan informasi yang kamu berikan secara langsung, termasuk:\n\n'
          '• Informasi akun: nama, alamat email, nomor telepon, dan kata sandi terenkripsi.\n'
          '• Informasi medis: informasi penyakit kamu unggah untuk tujuan diagnosis.\n'
          '• Informasi penggunaan: data aktivitas di dalam aplikasi untuk meningkatkan layanan.\n'
          '• Informasi perangkat: tipe perangkat, sistem operasi, dan ID perangkat.',
    },
    {
      'icon': Icons.manage_search_rounded,
      'title': '2. Cara Kami Menggunakan Informasi',
      'content':
          'Informasi yang dikumpulkan digunakan untuk:\n\n'
          '• Menyediakan dan meningkatkan layanan diagnosis penyakit berbasis AI.\n'
          '• Menghubungkan kamu dengan dokter konsultasi.\n'
          '• Mengirimkan notifikasi dan pembaruan layanan.\n'
          '• Menganalisis dan meningkatkan akurasi model AI kami.\n'
          '• Memenuhi kewajiban hukum dan regulasi yang berlaku.',
    },
    {
      'icon': Icons.share_outlined,
      'title': '3. Berbagi Informasi',
      'content':
          'Kami tidak menjual data pribadi kamu kepada pihak ketiga. '
          'Informasi dapat dibagikan kepada:\n\n'
          '• Dokter yang kamu pilih untuk berkonsultasi (hanya data relevan).\n'
          '• Penyedia layanan teknologi yang membantu operasional kami.\n'
          '• Otoritas hukum jika diwajibkan oleh peraturan perundangan.',
    },
    {
      'icon': Icons.lock_outline_rounded,
      'title': '4. Keamanan Data',
      'content':
          'Kami menerapkan langkah-langkah keamanan teknis dan organisasi yang ketat:\n\n'
          '• Enkripsi AES-256 untuk data yang tersimpan.\n'
          '• Enkripsi TLS 1.3 untuk data yang dikirimkan.\n'
          '• Kontrol akses berbasis peran (RBAC) untuk staf kami.\n'
          '• Audit keamanan dan penetration testing secara berkala.\n'
          '• Server berlokasi di Indonesia sesuai regulasi PDPA.',
    },
    {
      'icon': Icons.person_outline_rounded,
      'title': '5. Hak-Hak Pengguna',
      'content':
          'Kamu memiliki hak untuk:\n\n'
          '• Mengakses data pribadi yang kami miliki tentang kamu.\n'
          '• Memperbaiki data yang tidak akurat atau tidak lengkap.\n'
          '• Menghapus akun dan seluruh data kamu dari sistem kami.\n'
          '• Membatasi atau menolak pemrosesan data kamu.\n'
          '• Meminta salinan data kamu dalam format yang dapat dibaca mesin.',
    },
    {
      'icon': Icons.child_care_rounded,
      'title': '6. Privasi Anak-Anak',
      'content':
          'Layanan kami tidak ditujukan untuk pengguna di bawah usia 17 tahun, terkecuali dengan pengawasan . '
          'Kami tidak secara sengaja mengumpulkan informasi dari anak-anak. '
          'Jika kamu percaya bahwa anak kamu telah memberikan informasi pribadi kepada kami, '
          'silakan hubungi kami segera agar kami dapat menghapus data tersebut.',
    },
    {
      'icon': Icons.update_rounded,
      'title': '7. Perubahan Kebijakan',
      'content':
          'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. '
          'Kami akan memberitahu kamu tentang perubahan signifikan melalui:\n\n'
          '• Notifikasi push di aplikasi.\n'
          '• Email ke alamat yang terdaftar.\n'
          '• Pemberitahuan di halaman utama aplikasi.\n\n'
          'Penggunaan layanan setelah tanggal berlakunya kebijakan baru merupakan '
          'persetujuan kamu terhadap kebijakan yang diperbarui.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color.fromARGB(255, 27, 40, 10), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kebijakan Privasi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.privacy_tip_rounded,
                    color: AppTheme.primaryTeal, size: 24),
              ),
              const SizedBox(height: 14),
              const Text('Kebijakan Privasi',
                  style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              Text('Terakhir diperbarui: 20 April 2026',
                  style: TextStyle(color: Colors.white.withOpacity(0.6),
                      fontSize: 11, fontFamily: 'Poppins')),
              const SizedBox(height: 10),
              Text(
                'Kami berkomitmen untuk melindungi privasi dan keamanan data '
                'pribadi kamu. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, '
                'menggunakan, dan melindungi informasimu.',
                style: TextStyle(color: Colors.white.withOpacity(0.8),
                    fontSize: 12, fontFamily: 'Poppins', height: 1.5),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          ..._sections.map((s) => _PolicySection(
            icon: s['icon'] as IconData,
            title: s['title'] as String,
            content: s['content'] as String,
          )),

          // Contact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hubungi Kami',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              _contactRow(Icons.email_outlined,
                  'bayuurokhmatullah@'),
              const SizedBox(height: 6),
              _contactRow(Icons.location_on_outlined,
                  'Jl. Gn. Bromo Blok 12 No. 17, Margadadi, Kabupaten Indramayu, Jawa Barat, Indonesia'),
            ]),
          ),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppTheme.primaryTeal, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary,
                fontFamily: 'Poppins')),
      ),
    ],
  );
}

class _PolicySection extends StatefulWidget {
  final IconData icon;
  final String title, content;
  const _PolicySection({required this.icon, required this.title,
      required this.content});

  @override
  State<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends State<_PolicySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A7BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon,
                    color: const Color(0xFF3A7BD5), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.title,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: _expanded
                            ? const Color(0xFF3A7BD5)
                            : AppTheme.textPrimary)),
              ),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textMuted, size: 20),
            ]),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Text(widget.content,
                  style: const TextStyle(fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Poppins', height: 1.7)),
            ),
        ]),
      ),
    );
  }
}