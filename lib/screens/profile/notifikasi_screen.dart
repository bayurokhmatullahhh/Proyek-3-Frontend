import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _notifDiagnosis = true;
  bool _notifKonsultasi = true;
  bool _notifPromo = false;
  bool _notifBerita = true;
  bool _notifPengingat = true;
  bool _notifHasil = true;

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
        title: const Text('Notifikasi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('AKTIVITAS', [
            _NotifItem(
              icon: Icons.biotech_rounded,
              color: const Color(0xFF00D4AA),
              title: 'Hasil Diagnosis',
              subtitle: 'Notifikasi saat hasil diagnosis selesai diproses',
              value: _notifHasil,
              onChanged: (v) => setState(() => _notifHasil = v),
            ),
            _NotifItem(
              icon: Icons.medical_services_rounded,
              color: const Color(0xFF667EEA),
              title: 'Konsultasi Dokter',
              subtitle: 'Notifikasi jadwal dan pesan dari dokter',
              value: _notifKonsultasi,
              onChanged: (v) => setState(() => _notifKonsultasi = v),
            ),
            _NotifItem(
              icon: Icons.alarm_rounded,
              color: const Color(0xFFF59E0B),
              title: 'Pengingat Perawatan',
              subtitle: 'Ingatkan waktu pemakaian skincare & obat',
              value: _notifPengingat,
              onChanged: (v) => setState(() => _notifPengingat = v),
            ),
          ]),

          const SizedBox(height: 8),

          _buildSection('INFORMASI', [
            _NotifItem(
              icon: Icons.newspaper_rounded,
              color: const Color(0xFF22C55E),
              title: 'Berita Kesehatan Kulit',
              subtitle: 'Artikel dan tips terbaru seputar kesehatan kulit',
              value: _notifBerita,
              onChanged: (v) => setState(() => _notifBerita = v),
            ),
            _NotifItem(
              icon: Icons.local_offer_rounded,
              color: const Color(0xFFEF4444),
              title: 'Promo & Penawaran',
              subtitle: 'Diskon dan penawaran spesial dari DermaScan',
              value: _notifPromo,
              onChanged: (v) => setState(() => _notifPromo = v),
            ),
          ]),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppTheme.primaryTeal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kamu dapat mengubah izin notifikasi melalui pengaturan perangkat.',
                  style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal,
                      fontFamily: 'Poppins',
                      height: 1.5),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppTheme.textMuted, letterSpacing: 0.9,
              fontFamily: 'Poppins')),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(children: [
              entry.value,
              if (!isLast)
                Divider(height: 1, indent: 60, color: AppTheme.divider),
            ]);
          }).toList(),
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifItem({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted,
                  fontFamily: 'Poppins')),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryTeal,
        ),
      ]),
    );
  }
}