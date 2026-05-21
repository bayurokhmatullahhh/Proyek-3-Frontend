import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _bmiResult;
  String _bmiCategory = '';
  Color _bmiColor = AppTheme.primaryTeal;
  String _bmiMessage = '';

  void _calculateBMI() {
    FocusScope.of(context).unfocus();
    final double? weight = double.tryParse(_weightController.text);
    final double? heightCm = double.tryParse(_heightController.text);

    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan berat dan tinggi badan yang valid', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final double heightM = heightCm / 100;
    final double bmi = weight / pow(heightM, 2);

    setState(() {
      _bmiResult = bmi;
      if (bmi < 18.5) {
        _bmiCategory = 'Kekurangan Berat Badan';
        _bmiColor = AppTheme.warning;
        _bmiMessage = 'Coba tingkatkan asupan kalori bernutrisi dan konsultasikan dengan ahli gizi.';
      } else if (bmi >= 18.5 && bmi < 24.9) {
        _bmiCategory = 'Normal (Ideal)';
        _bmiColor = AppTheme.success;
        _bmiMessage = 'Bagus! Pertahankan gaya hidup sehat, pola makan, dan olahraga rutin Anda.';
      } else if (bmi >= 25 && bmi < 29.9) {
        _bmiCategory = 'Kelebihan Berat Badan';
        _bmiColor = AppTheme.accentOrange;
        _bmiMessage = 'Perhatikan pola makan Anda dan pertimbangkan untuk meningkatkan aktivitas fisik.';
      } else {
        _bmiCategory = 'Obesitas';
        _bmiColor = AppTheme.danger;
        _bmiMessage = 'Sangat disarankan untuk berkonsultasi dengan dokter atau ahli kesehatan.';
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Cek Kesehatan'),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Column(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Kalkulator BMI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cek Body Mass Index (BMI) untuk mengetahui status berat badan ideal Anda.',
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berat Badan (kg)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Misal: 65',
                      prefixIcon: const Icon(Icons.fitness_center_rounded, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tinggi Badan (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Misal: 170',
                      prefixIcon: const Icon(Icons.height_rounded, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Hitung BMI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_bmiResult != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: _bmiColor.withOpacity(0.3), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hasil BMI Anda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _bmiResult!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _bmiColor,
                        height: 1.1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bmiColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _bmiCategory,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _bmiColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _bmiMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
