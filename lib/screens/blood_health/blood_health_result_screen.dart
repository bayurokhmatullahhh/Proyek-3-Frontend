import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BloodHealthResultScreen extends StatelessWidget {
  final String nama;
  final int umur;
  final String jenisKelamin;
  final int sistolik;
  final int diastolik;
  final double gulaDarah;
  final double kolesterol;
  final double asamUrat;

  const BloodHealthResultScreen({
    super.key,
    required this.nama,
    required this.umur,
    required this.jenisKelamin,
    required this.sistolik,
    required this.diastolik,
    required this.gulaDarah,
    required this.kolesterol,
    required this.asamUrat,
  });

  Map<String, dynamic> _calculateBP() {
    if (sistolik < 120 && diastolik < 80) return {'status': 'Normal', 'icon': '✅', 'color': Colors.green};
    if (sistolik >= 140 || diastolik >= 90) return {'status': 'Tinggi', 'icon': '⚠️', 'color': Colors.red};
    return {'status': 'Perlu Perhatian', 'icon': '🟡', 'color': Colors.orange};
  }

  Map<String, dynamic> _calculateSugar() {
    if (gulaDarah < 100) return {'status': 'Normal', 'icon': '✅', 'color': Colors.green};
    if (gulaDarah >= 126) return {'status': 'Tinggi', 'icon': '⚠️', 'color': Colors.red};
    return {'status': 'Perlu Perhatian', 'icon': '🟡', 'color': Colors.orange};
  }

  Map<String, dynamic> _calculateCholesterol() {
    if (kolesterol < 200) return {'status': 'Normal', 'icon': '✅', 'color': Colors.green};
    if (kolesterol >= 240) return {'status': 'Tinggi', 'icon': '⚠️', 'color': Colors.red};
    return {'status': 'Perlu Perhatian', 'icon': '🟡', 'color': Colors.orange};
  }

  Map<String, dynamic> _calculateUricAcid() {
    double min = jenisKelamin == 'Pria' ? 3.4 : 2.4;
    double max = jenisKelamin == 'Pria' ? 7.0 : 6.0;

    if (asamUrat >= min && asamUrat <= max) return {'status': 'Normal', 'icon': '✅', 'color': Colors.green};
    if (asamUrat > max) return {'status': 'Tinggi', 'icon': '⚠️', 'color': Colors.red};
    return {'status': 'Rendah', 'icon': '⚠️', 'color': Colors.orange};
  }

  int _calculateHealthScore() {
    int score = 100;
    
    var bp = _calculateBP()['status'];
    if (bp == 'Perlu Perhatian') score -= 10;
    if (bp == 'Tinggi') score -= 20;

    var sg = _calculateSugar()['status'];
    if (sg == 'Perlu Perhatian') score -= 10;
    if (sg == 'Tinggi') score -= 20;

    var chol = _calculateCholesterol()['status'];
    if (chol == 'Perlu Perhatian') score -= 10;
    if (chol == 'Tinggi') score -= 20;

    var ua = _calculateUricAcid()['status'];
    if (ua != 'Normal') score -= 15;

    return score < 0 ? 0 : score;
  }

  String _getConclusion(int score) {
    if (score >= 80) return 'Semua indikator kesehatan berada pada nilai yang baik. Pertahankan gaya hidup sehat Anda dengan pola makan bergizi dan olahraga teratur.';
    if (score >= 60) return 'Beberapa indikator kesehatan menunjukkan nilai di luar batas normal. Disarankan menjaga pola makan, berolahraga, dan melakukan konsultasi lanjutan jika perlu.';
    return 'Banyak indikator berada di zona risiko tinggi. Sangat disarankan untuk segera berkonsultasi dengan dokter untuk penanganan medis lebih lanjut.';
  }

  Map<String, dynamic> _getScoreTier(int score) {
    if (score >= 80) return {'label': 'Sehat', 'color': Colors.green, 'icon': Icons.sentiment_very_satisfied_rounded};
    if (score >= 60) return {'label': 'Perlu Perhatian', 'color': Colors.orange, 'icon': Icons.sentiment_neutral_rounded};
    return {'label': 'Risiko Tinggi', 'color': Colors.red, 'icon': Icons.sentiment_very_dissatisfied_rounded};
  }

  Widget _buildResultRow(String title, String value, Map<String, dynamic> status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          Expanded(flex: 1, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(status['status'], style: TextStyle(fontWeight: FontWeight.bold, color: status['color'])),
                const SizedBox(width: 4),
                Text(status['icon']),
              ],
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int score = _calculateHealthScore();
    var tier = _getScoreTier(score);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text('Hasil Pemeriksaan', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Card / Health Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tier['color'].withOpacity(0.8), tier['color']],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: tier['color'].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$umur Tahun • $jenisKelamin', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      Icon(tier['icon'], color: Colors.white, size: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Health Score', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$score', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
                          const Text('/100', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(tier['label'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            const Text('Rincian Hasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(flex: 2, child: Text('Pemeriksaan', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Hasil', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  const Divider(),
                  _buildResultRow('Tekanan Darah', '$sistolik/$diastolik', _calculateBP()),
                  const Divider(height: 1),
                  _buildResultRow('Gula Darah', gulaDarah.toStringAsFixed(0), _calculateSugar()),
                  const Divider(height: 1),
                  _buildResultRow('Kolesterol', kolesterol.toStringAsFixed(0), _calculateCholesterol()),
                  const Divider(height: 1),
                  _buildResultRow('Asam Urat', asamUrat.toStringAsFixed(1), _calculateUricAcid()),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Text('Kesimpulan & Saran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tier['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tier['color'].withOpacity(0.3))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: tier['color'], size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getConclusion(score),
                      style: const TextStyle(color: AppTheme.textPrimary, height: 1.5, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFF43F5E), width: 2)
                ),
                child: const Text('Periksa Ulang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
