import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  // Questions list
  final List<String> _questions = [
    'Apakah akhir-akhir ini kamu sering merasa sedih atau murung?',
    'Apakah kamu mengalami kesulitan tidur atau pola tidur berantakan?',
    'Apakah kamu merasa cemas, gelisah, atau khawatir berlebihan?',
    'Apakah kamu kehilangan semangat untuk melakukan aktivitas yang biasanya disukai?',
  ];

  // Map to store selected answers (question index -> score)
  final Map<int, int> _answers = {};

  bool _isSubmitted = false;
  int _totalScore = 0;

  final List<Map<String, dynamic>> _options = [
    {'label': 'Tidak Pernah', 'score': 0, 'icon': Icons.sentiment_very_satisfied_rounded, 'color': AppTheme.success},
    {'label': 'Kadang-kadang', 'score': 1, 'icon': Icons.sentiment_satisfied_rounded, 'color': AppTheme.info},
    {'label': 'Sering', 'score': 2, 'icon': Icons.sentiment_dissatisfied_rounded, 'color': AppTheme.warning},
    {'label': 'Sangat Sering', 'score': 3, 'icon': Icons.sentiment_very_dissatisfied_rounded, 'color': AppTheme.danger},
  ];

  void _submitTest() {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua pertanyaan terlebih dahulu.', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    int score = 0;
    _answers.forEach((key, value) {
      score += value;
    });

    setState(() {
      _totalScore = score;
      _isSubmitted = true;
    });
  }

  void _resetTest() {
    setState(() {
      _answers.clear();
      _isSubmitted = false;
      _totalScore = 0;
    });
  }

  Widget _buildResultSection() {
    String resultTitle = '';
    String resultDesc = '';
    Color resultColor = AppTheme.primaryTeal;
    String resultEmoji = '';

    // Max score is 12 (4 questions * max score 3)
    if (_totalScore <= 3) {
      resultTitle = 'Kondisi Baik';
      resultEmoji = '😊';
      resultColor = AppTheme.success;
      resultDesc = 'Kondisi mental kamu saat ini cukup baik. Tetap jaga pola makan, tidur teratur, dan lakukan hal-hal yang membuatmu bahagia!';
    } else if (_totalScore <= 7) {
      resultTitle = 'Stress Ringan';
      resultEmoji = '😐';
      resultColor = AppTheme.warning;
      resultDesc = 'Kamu mungkin sedang mengalami tekanan atau stres ringan. Coba luangkan waktu untuk relaksasi, curhat dengan orang terdekat, atau lakukan hobi yang kamu suka.';
    } else {
      resultTitle = 'Perlu Konsultasi';
      resultEmoji = '😔';
      resultColor = AppTheme.danger;
      resultDesc = 'Tingkat stres atau kecemasan kamu cukup tinggi. Sangat disarankan untuk berbicara dengan profesional, dokter, atau psikolog agar mendapat penanganan yang tepat.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.elevatedShadow,
        border: Border.all(color: resultColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            resultEmoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            resultTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: resultColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            resultDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: resultColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Cek Ulang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Kesehatan Mental'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner/Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mental Health Self-Check',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cek kondisi emosionalmu saat ini untuk mengetahui langkah terbaik yang bisa diambil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isSubmitted)
              _buildResultSection()
            else ...[
              // Tips card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentBlue),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tips Hari Ini', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentBlue, fontFamily: 'Poppins')),
                          SizedBox(height: 4),
                          Text('Cobalah tarik napas dalam 4 detik, tahan 7 detik, dan hembuskan 8 detik untuk menenangkan pikiran.', 
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontFamily: 'Poppins', height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Jawab pertanyaan berikut dengan jujur berdasarkan apa yang kamu rasakan akhir-akhir ini.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              
              ...List.generate(_questions.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.accentPurple,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _questions[index],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                fontFamily: 'Poppins',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _options.map((option) {
                          final isSelected = _answers[index] == option['score'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _answers[index] = option['score'] as int;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? option['color'].withOpacity(0.1) : AppTheme.bgLight,
                                border: Border.all(
                                  color: isSelected ? option['color'] : AppTheme.divider,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    option['icon'],
                                    size: 18,
                                    color: isSelected ? option['color'] : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    option['label'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? option['color'] : AppTheme.textSecondary,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Hasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
