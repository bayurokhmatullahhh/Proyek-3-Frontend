import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'blood_health_result_screen.dart';

class BloodHealthScreen extends StatefulWidget {
  const BloodHealthScreen({super.key});

  @override
  State<BloodHealthScreen> createState() => _BloodHealthScreenState();
}

class _BloodHealthScreenState extends State<BloodHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _sistolikController = TextEditingController();
  final _diastolikController = TextEditingController();
  final _gulaDarahController = TextEditingController();
  final _kolesterolController = TextEditingController();
  final _asamUratController = TextEditingController();
  
  String _jenisKelamin = 'Pria';

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _sistolikController.dispose();
    _diastolikController.dispose();
    _gulaDarahController.dispose();
    _kolesterolController.dispose();
    _asamUratController.dispose();
    super.dispose();
  }

  void _analyzeData() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BloodHealthResultScreen(
            nama: _namaController.text,
            umur: int.parse(_umurController.text),
            jenisKelamin: _jenisKelamin,
            sistolik: int.parse(_sistolikController.text),
            diastolik: int.parse(_diastolikController.text),
            gulaDarah: double.parse(_gulaDarahController.text.replaceAll(',', '.')),
            kolesterol: double.parse(_kolesterolController.text.replaceAll(',', '.')),
            asamUrat: double.parse(_asamUratController.text.replaceAll(',', '.')),
          ),
        ),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType type = TextInputType.number,
    String? suffix,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Wajib diisi';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryTeal)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text('Kesehatan Darah', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF43F5E)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFEC4899).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.bloodtype, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Analisis Kesehatan Darah', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Ketahui status tekanan darah, gula darah, kolesterol, dan asam urat Anda secara instan.', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Profil Diri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _buildInputField(label: 'Nama Lengkap', controller: _namaController, hint: 'Contoh: Budi Santoso', type: TextInputType.text),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Umur', controller: _umurController, hint: 'Contoh: 35', suffix: 'Thn')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _jenisKelamin,
                              isExpanded: true,
                              items: ['Pria', 'Wanita'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _jenisKelamin = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text('Data Pemeriksaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Tekanan Sistolik', controller: _sistolikController, hint: '120')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField(label: 'Tekanan Diastolik', controller: _diastolikController, hint: '80')),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField(label: 'Gula Darah', controller: _gulaDarahController, hint: 'Contoh: 95', suffix: 'mg/dL'),
              const SizedBox(height: 16),
              _buildInputField(label: 'Kolesterol', controller: _kolesterolController, hint: 'Contoh: 180', suffix: 'mg/dL'),
              const SizedBox(height: 16),
              _buildInputField(label: 'Asam Urat', controller: _asamUratController, hint: 'Contoh: 5.2', suffix: 'mg/dL', type: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text('Analisa Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
