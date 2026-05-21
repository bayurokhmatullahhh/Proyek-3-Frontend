import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RekamMedisScreen extends StatelessWidget {
  const RekamMedisScreen({super.key});

  static const List<Map<String, dynamic>> _records = [
    {
      'date': '18 Apr 2025',
      'title': 'Pemeriksaan Kulit Rutin',
      'doctor': 'Dr. Andi Pratama, Sp.KK',
      'diagnosis': 'Dermatitis Atopik Ringan',
      'notes': 'Disarankan memakai pelembab 2x sehari dan hindari sabun keras.',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF00D4AA),
    },
    {
      'date': '02 Mar 2025',
      'title': 'Konsultasi Jerawat',
      'doctor': 'Dr. Rina Susanti, Sp.KK',
      'diagnosis': 'Acne Vulgaris Grade II',
      'notes': 'Resep: Adapalene 0.1% gel, Clindamycin lotion. Kontrol 1 bulan lagi.',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFF667EEA),
    },
    {
      'date': '15 Jan 2025',
      'title': 'Pemeriksaan Flek & Pigmentasi',
      'doctor': 'Dr. Andi Pratama, Sp.KK',
      'diagnosis': 'Melasma tipe Epidermal',
      'notes': 'Gunakan sunscreen SPF 50 setiap pagi. Hindari paparan matahari langsung.',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFFF59E0B),
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
              color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rekam Medis',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.medical_information_rounded,
                    color: AppTheme.primaryTeal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Riwayat Medis Kulit',
                      style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  const SizedBox(height: 2),
                  Text('${_records.length} catatan ditemukan',
                      style: TextStyle(color: Colors.white.withOpacity(0.6),
                          fontSize: 12, fontFamily: 'Poppins')),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),
          const Text('RIWAYAT KUNJUNGAN',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted, letterSpacing: 0.9,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 12),

          ..._records.map((r) => _RecordCard(record: r)),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: (record['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(record['icon'] as IconData,
                color: record['color'] as Color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record['title'] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Text(record['doctor'] as String,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (record['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(record['diagnosis'] as String,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: record['color'] as Color, fontFamily: 'Poppins')),
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(record['date'] as String,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.textMuted),
          ]),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: (record['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(record['icon'] as IconData,
                color: record['color'] as Color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(record['title'] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(record['date'] as String,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          _detailRow('Dokter', record['doctor'] as String),
          _detailRow('Diagnosis', record['diagnosis'] as String,
              highlight: record['color'] as Color),
          _detailRow('Catatan', record['notes'] as String),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? highlight}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight != null
            ? highlight.withOpacity(0.08) : AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted,
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: highlight ?? AppTheme.textPrimary)),
      ]),
    ),
  );
}