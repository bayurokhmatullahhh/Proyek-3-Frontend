import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class AsuransiBpjsScreen extends StatelessWidget {
  const AsuransiBpjsScreen({super.key});

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
        title: const Text('Asuransi & BPJS',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // BPJS Card
          _BpjsCard(),
          const SizedBox(height: 20),

          // Asuransi Swasta
          const Text('ASURANSI SWASTA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted, letterSpacing: 0.9,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          _InsuranceCard(
            name: 'Prudential Health',
            policyNo: 'PRU-2024-00123456',
            type: 'Rawat Jalan & Rawat Inap',
            expiry: '31 Des 2025',
            color: const Color(0xFF667EEA),
            icon: Icons.health_and_safety_rounded,
          ),
          const SizedBox(height: 12),
          _InsuranceCard(
            name: 'Allianz Care',
            policyNo: 'ALZ-2024-78901234',
            type: 'Rawat Inap',
            expiry: '30 Jun 2025',
            color: const Color(0xFFF59E0B),
            icon: Icons.local_hospital_rounded,
          ),

          const SizedBox(height: 20),

          // Tambah Asuransi button
          GestureDetector(
            onTap: () => _showAddInsurance(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppTheme.primaryTeal.withOpacity(0.4),
                    style: BorderStyle.solid),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Column(children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: AppTheme.primaryTeal, size: 28),
                SizedBox(height: 6),
                Text('Tambah Asuransi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTeal, fontFamily: 'Poppins')),
              ]),
            ),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  void _showAddInsurance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Tambah Asuransi',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            _inputField('Nama Perusahaan Asuransi'),
            const SizedBox(height: 12),
            _inputField('Nomor Polis'),
            const SizedBox(height: 12),
            _inputField('Jenis Pertanggungan'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Asuransi berhasil ditambahkan!',
                          style: TextStyle(fontFamily: 'Poppins')),
                      backgroundColor: AppTheme.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan',
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _inputField(String hint) => TextField(
    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins',
        color: AppTheme.textPrimary),
    decoration: InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppTheme.textMuted),
      filled: true,
      fillColor: AppTheme.bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _BpjsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009A44), Color(0xFF00C851)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009A44).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('BPJS KESEHATAN',
                style: TextStyle(color: Colors.white, fontSize: 11,
                    fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                    letterSpacing: 0.5)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('AKTIF',
                style: TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ),
        ]),
        const SizedBox(height: 20),
        const Text('Nomor Peserta',
            style: TextStyle(color: Colors.white70, fontSize: 11,
                fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: '0001234567890'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Nomor disalin!',
                    style: TextStyle(fontFamily: 'Poppins')),
                backgroundColor: const Color(0xFF009A44),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Row(children: [
            const Text('0001 2345 6789 0',
                style: TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                    letterSpacing: 1.5)),
            const SizedBox(width: 8),
            const Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nama Peserta',
                style: TextStyle(color: Colors.white70, fontSize: 10,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            const Text('TEST PENGGUNA',
                style: TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Kelas',
                style: TextStyle(color: Colors.white70, fontSize: 10,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            const Text('Kelas 1',
                style: TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ]),
        ]),
        const SizedBox(height: 12),
        Divider(color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          const Text('Faskes: Puskesmas Indramayu I',
              style: TextStyle(color: Colors.white70, fontSize: 11,
                  fontFamily: 'Poppins')),
        ]),
      ]),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  final String name, policyNo, type, expiry;
  final Color color;
  final IconData icon;

  const _InsuranceCard({
    required this.name,
    required this.policyNo,
    required this.type,
    required this.expiry,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 3),
          Text(policyNo,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(type,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: color, fontFamily: 'Poppins')),
            ),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('Berlaku s.d.',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 2),
          Text(expiry,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        ]),
      ]),
    );
  }
}