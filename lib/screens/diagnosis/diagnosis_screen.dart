import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../profile/result_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  final Set<String>  _selectedKeys  = {};   // snake_case keys
  final _ageCtrl = TextEditingController();
  bool   _isLoading = false;
  String? _error;
  String  _searchQuery = '';

  // ── Symptom list: display label → snake_case key ──────────────
  // Semua dari feature_names di diagnosis_meta.json lo
  static const Map<String, String> _allSymptoms = {
    'Gatal':                    'itching',
    'Ruam Kulit':               'skin_rash',
    'Bintik Kulit':             'nodal_skin_eruptions',
    'Bersin Terus':             'continuous_sneezing',
    'Menggigil':                'shivering',
    'Dingin/Kedinginan':        'chills',
    'Nyeri Sendi':              'joint_pain',
    'Sakit Perut':              'stomach_pain',
    'Asam Lambung':             'acidity',
    'Sariawan':                 'ulcers_on_tongue',
    'Mual':                     'nausea',
    'Muntah':                   'vomiting',
    'Hilang Nafsu Makan':       'loss_of_appetite',
    'Lemas/Kelelahan':          'fatigue',
    'Nyeri Perut':              'abdominal_pain',
    'Sakit Kepala':             'headache',
    'Demam Tinggi':             'high_fever',
    'Demam Ringan':             'mild_fever',
    'Diare':                    'diarrhoea',
    'Batuk':                    'cough',
    'Sesak Napas':              'breathlessness',
    'Nyeri Dada':               'chest_pain',
    'Pusing':                   'dizziness',
    'Sembelit':                 'constipation',
    'Otot Lemah':               'muscle_wasting',
    'Kulit Menguning':          'yellowing_of_eyes',
    'Kulit Kekuningan':         'yellowish_skin',
    'Berat Badan Turun':        'weight_loss',
    'Berat Badan Naik':         'weight_gain',
    'Nyeri Punggung':           'back_pain',
    'Nyeri Leher':              'neck_pain',
    'Keringat Berlebih':        'sweating',
    'Depresi':                  'depression',
    'Kecemasan':                'anxiety',
    'Detak Jantung Cepat':      'fast_heart_rate',
    'Sulit Konsentrasi':        'lack_of_concentration',
    'Perubahan Mood':           'mood_swings',
    'Gelisah':                  'restlessness',
    'Lesu':                     'lethargy',
    'Pembengkakan Sendi':       'swelling_joints',
    'Kaki Bengkak':             'swollen_legs',
    'Wajah Sembab':             'puffy_face_and_eyes',
    'Mata Berair':              'watering_from_eyes',
    'Mata Merah':               'redness_of_eyes',
    'Penglihatan Kabur':        'blurred_and_distorted_vision',
    'Hidung Tersumbat':         'congestion',
    'Hidung Berair':            'runny_nose',
    'Tenggorokan Gatal':        'throat_irritation',
    'Bercak di Tenggorokan':    'patches_in_throat',
    'Dahak Berlendir':          'mucoid_sputum',
    'Dahak Berdarah':           'blood_in_sputum',
    'Nafas Berbunyi':           'phlegm',
    'Nyeri Lutut':              'knee_pain',
    'Nyeri Pinggul':            'hip_joint_pain',
    'Kaku Sendi':               'movement_stiffness',
    'Leher Kaku':               'stiff_neck',
    'Nyeri Otot':               'muscle_pain',
    'Kelemahan Anggota Tubuh':  'weakness_in_limbs',
    'Urine Gelap':              'dark_urine',
    'Urine Berbau':             'foul_smell_of_urine',
    'Buang Air Kecil Sakit':    'burning_micturition',
    'Sering Buang Air Kecil':   'polyuria',
    'Perut Kembung':            'distention_of_abdomen',
    'BAB Berdarah':             'bloody_stool',
    'Dehydrasi':                'dehydration',
    'Perdarahan Lambung':       'stomach_bleeding',
    'Mata Cekung':              'sunken_eyes',
    'Kulit Mengelupas':         'skin_peeling',
    'Jerawat Bernanah':         'pus_filled_pimples',
    'Komedo':                   'blackheads',
    'Kelenjar Bengkak':         'swelled_lymph_nodes',
    'Pembuluh Vena Menonjol':   'prominent_veins_on_calf',
    'Obesitas':                 'obesity',
    'Nafsu Makan Bertambah':    'increased_appetite',
    'Gula Darah Tidak Stabil':  'irregular_sugar_level',
    'Tiroid Membesar':          'enlarged_thyroid',
    'Tremor':                   'spinning_movements',
    'Bicara Cadel':             'slurred_speech',
    'Kehilangan Keseimbangan':  'loss_of_balance',
    'Kehilangan Penciuman':     'loss_of_smell',
    'Kaki & Tangan Dingin':     'cold_hands_and_feets',
    'Kulit Berkilau (Perak)':   'silver_like_dusting',
    'Tekanan Sinus':            'sinus_pressure',
    'Nyeri di Balik Mata':      'pain_behind_the_eyes',
    'Malaise':                  'malaise',
    'Penampilan Toksik':        'toxic_look_(typhos)',
  };

  // Kategori untuk UI yang lebih terstruktur
  static const Map<String, List<String>> _categories = {
    '🌡️ Demam & Suhu': [
      'Demam Tinggi', 'Demam Ringan', 'Menggigil', 'Dingin/Kedinginan', 'Keringat Berlebih',
    ],
    '😷 Pernapasan': [
      'Batuk', 'Sesak Napas', 'Bersin Terus', 'Hidung Tersumbat', 'Hidung Berair',
      'Dahak Berlendir', 'Dahak Berdarah', 'Nafas Berbunyi', 'Tenggorokan Gatal',
      'Bercak di Tenggorokan',
    ],
    '🤢 Pencernaan': [
      'Mual', 'Muntah', 'Diare', 'Sakit Perut', 'Nyeri Perut', 'Asam Lambung',
      'Hilang Nafsu Makan', 'Sembelit', 'Perut Kembung', 'BAB Berdarah',
      'Perdarahan Lambung', 'Dehydrasi',
    ],
    '🦴 Nyeri & Otot': [
      'Nyeri Sendi', 'Nyeri Dada', 'Nyeri Punggung', 'Nyeri Leher', 'Nyeri Lutut',
      'Nyeri Pinggul', 'Nyeri Otot', 'Kaki & Tangan Dingin', 'Kaku Sendi', 'Leher Kaku',
      'Kelemahan Anggota Tubuh', 'Otot Lemah',
    ],
    '🧠 Neurologis': [
      'Sakit Kepala', 'Pusing', 'Tremor', 'Bicara Cadel', 'Kehilangan Keseimbangan',
      'Kehilangan Penciuman', 'Penglihatan Kabur', 'Mata Berair', 'Mata Merah',
      'Nyeri di Balik Mata',
    ],
    '😔 Mental & Umum': [
      'Lemas/Kelelahan', 'Lesu', 'Depresi', 'Kecemasan', 'Gelisah', 'Perubahan Mood',
      'Sulit Konsentrasi', 'Malaise',
    ],
    '🩺 Kulit & Luar': [
      'Gatal', 'Ruam Kulit', 'Bintik Kulit', 'Kulit Menguning', 'Kulit Kekuningan',
      'Kulit Mengelupas', 'Jerawat Bernanah', 'Komedo', 'Sariawan',
      'Kulit Berkilau (Perak)',
    ],
    '💧 Urine & Ginjal': [
      'Urine Gelap', 'Urine Berbau', 'Buang Air Kecil Sakit', 'Sering Buang Air Kecil',
    ],
    '❤️ Jantung & Sirkulasi': [
      'Detak Jantung Cepat', 'Pembuluh Vena Menonjol', 'Kaki Bengkak',
      'Wajah Sembab', 'Pembengkakan Sendi', 'Kelenjar Bengkak',
    ],
    '⚖️ Metabolisme': [
      'Berat Badan Turun', 'Berat Badan Naik', 'Obesitas', 'Nafsu Makan Bertambah',
      'Gula Darah Tidak Stabil', 'Tiroid Membesar', 'Dehydrasi',
    ],
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() => _error = null);

    if (_selectedKeys.isEmpty) {
      setState(() => _error = 'Pilih minimal 1 gejala.');
      return;
    }
    if (_ageCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Isi usia kamu.');
      return;
    }

    setState(() => _isLoading = true);

    // Kirim snake_case keys ke API
    final symptoms = _selectedKeys.toList();

    try {
      final result = await ApiService.assess(
        symptoms: symptoms,
        age: int.tryParse(_ageCtrl.text.trim()) ?? 25,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(result: result),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.message; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = 'Error tidak terduga: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 190, floating: false, pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.navyGradient),
                child: Stack(children: [
                  Positioned(right: -40, top: -40, child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: AppTheme.primaryTeal.withOpacity(0.08)))),
                  SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.primaryTeal.withOpacity(0.4))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            ScaleTransition(scale: _pulseAnim,
                              child: const Icon(Icons.auto_awesome_rounded,
                                color: AppTheme.primaryTeal, size: 14)),
                            const SizedBox(width: 6),
                            const Text('AI Diagnosis Engine',
                              style: TextStyle(color: AppTheme.primaryTeal,
                                fontSize: 11, fontWeight: FontWeight.w700,
                                letterSpacing: 0.5, fontFamily: 'Poppins')),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        const Text('Prediksi\nDiagnosis Awal',
                          style: TextStyle(color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.w800, height: 1.2,
                            fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text('Pilih gejala yang kamu rasakan',
                          style: TextStyle(color: Colors.white.withOpacity(0.6),
                            fontSize: 13, fontFamily: 'Poppins')),
                      ]),
                  )),
                ]),
              ),
              title: const Text('Diagnosis AI',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                  fontSize: 16, fontFamily: 'Poppins')),
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              collapseMode: CollapseMode.pin,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Error banner
                  if (_error != null) ...[
                    _ErrorCard(message: _error!),
                    const SizedBox(height: 16),
                  ],

                  // ── Selected summary ──
                  if (_selectedKeys.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.tealGlow),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          '${_selectedKeys.length} gejala dipilih — siap dianalisis',
                          style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600, fontSize: 13,
                            fontFamily: 'Poppins'))),
                        GestureDetector(
                          onTap: () => setState(() => _selectedKeys.clear()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                            child: const Text('Reset',
                              style: TextStyle(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins')))),
                      ]),
                    ),

                  // ── Search ──
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider, width: 1.5)),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: const TextStyle(fontSize: 13, fontFamily: 'Poppins',
                        color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Cari gejala...',
                        hintStyle: TextStyle(color: AppTheme.textMuted,
                          fontSize: 13, fontFamily: 'Poppins'),
                        prefixIcon: Icon(Icons.search_rounded,
                          color: AppTheme.textMuted, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Kategori & chips ──
                  ..._buildCategoryChips(),

                  const SizedBox(height: 24),

                  // ── Usia ──
                  const Text('Usia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary, fontFamily: 'Poppins')),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider, width: 1.5)),
                    child: TextField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14,
                        color: AppTheme.textPrimary, fontFamily: 'Poppins'),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan usia kamu',
                        hintStyle: TextStyle(color: AppTheme.textMuted,
                          fontSize: 13, fontFamily: 'Poppins'),
                        prefixIcon: Icon(Icons.cake_rounded,
                          color: AppTheme.textMuted, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Analyze button ──
                  GestureDetector(
                    onTap: _isLoading ? null : _analyze,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity, height: 58,
                      decoration: BoxDecoration(
                        gradient: _isLoading || _selectedKeys.isEmpty
                            ? LinearGradient(colors: [
                                AppTheme.primaryTeal.withOpacity(0.5),
                                AppTheme.primaryTealDark.withOpacity(0.5)])
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _selectedKeys.isNotEmpty && !_isLoading
                            ? AppTheme.tealGlow : []),
                      child: Center(child: _isLoading
                          ? const SizedBox(width: 26, height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                          : Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                  color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedKeys.isEmpty
                                      ? 'Pilih Gejala Dulu'
                                      : 'Analisis ${_selectedKeys.length} Gejala',
                                  style: const TextStyle(color: Colors.white,
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins')),
                              ])),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.info.withOpacity(0.2))),
                    child: const Row(children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppTheme.info, size: 18),
                      SizedBox(width: 10),
                      Expanded(child: Text(
                        'Hasil prediksi bukan pengganti diagnosis dokter. '
                        'Selalu konsultasikan dengan tenaga medis.',
                        style: TextStyle(fontSize: 11, color: AppTheme.info,
                          fontWeight: FontWeight.w500, height: 1.5,
                          fontFamily: 'Poppins'))),
                    ]),
                  ),
                  const SizedBox(height: 100),
                ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips() {
    final widgets = <Widget>[];

    for (final entry in _categories.entries) {
      final catLabel = entry.key;
      final symptoms = entry.value;

      // Filter berdasarkan search
      final filtered = _searchQuery.isEmpty
          ? symptoms
          : symptoms.where((s) =>
              s.toLowerCase().contains(_searchQuery)).toList();

      if (filtered.isEmpty) continue;

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(catLabel,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary, fontFamily: 'Poppins',
              letterSpacing: 0.3)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8,
            children: filtered.map((label) {
              final key = _allSymptoms[label] ?? '';
              final sel = _selectedKeys.contains(key);
              return GestureDetector(
                onTap: () => setState(() {
                  sel ? _selectedKeys.remove(key) : _selectedKeys.add(key);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primaryNavy : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? AppTheme.primaryTeal : AppTheme.divider,
                      width: sel ? 1.5 : 1),
                    boxShadow: sel ? AppTheme.cardShadow : []),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) ...[
                      const Icon(Icons.check_rounded,
                        size: 12, color: AppTheme.primaryTeal),
                      const SizedBox(width: 4),
                    ],
                    Text(label,
                      style: TextStyle(fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: sel ? AppTheme.primaryTeal
                            : AppTheme.textSecondary)),
                  ]),
                ),
              );
            }).toList()),
        ]),
      ));
    }

    return widgets;
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message,
        style: const TextStyle(fontSize: 12, color: AppTheme.danger,
          fontFamily: 'Poppins', fontWeight: FontWeight.w500, height: 1.5))),
    ]),
  );
}



//END

// //KODE BARU 20-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class DiagnosisScreen extends StatefulWidget {
//   const DiagnosisScreen({super.key});

//   @override
//   State<DiagnosisScreen> createState() => _DiagnosisScreenState();
// }

// class _DiagnosisScreenState extends State<DiagnosisScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnim;
//   int _selectedUrgency = -1;
//   final List<String> _selectedSymptoms = [];

//   final List<_Symptom> _symptoms = const [
//     _Symptom(label: 'Demam', icon: Icons.thermostat_rounded),
//     _Symptom(label: 'Batuk', icon: Icons.air_rounded),
//     _Symptom(label: 'Sakit Kepala', icon: Icons.psychology_alt_rounded),
//     _Symptom(label: 'Nyeri Dada', icon: Icons.favorite_border_rounded),
//     _Symptom(label: 'Sesak Napas', icon: Icons.air_rounded),
//     _Symptom(label: 'Mual/Muntah', icon: Icons.sick_rounded),
//     _Symptom(label: 'Nyeri Perut', icon: Icons.local_hospital_rounded),
//     _Symptom(label: 'Pusing', icon: Icons.swap_vert_rounded),
//     _Symptom(label: 'Kelelahan', icon: Icons.battery_2_bar_rounded),
//     _Symptom(label: 'Diare', icon: Icons.water_drop_rounded),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.bgLight,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // Header
//           SliverAppBar(
//             expandedHeight: 200,
//             floating: false,
//             pinned: true,
//             backgroundColor: AppTheme.primaryNavy,
//             automaticallyImplyLeading: false,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: const BoxDecoration(gradient: AppTheme.navyGradient),
//                 child: Stack(
//                   children: [
//                     // Decorative
//                     Positioned(
//                       right: -40,
//                       top: -40,
//                       child: Container(
//                         width: 200,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: AppTheme.primaryTeal.withOpacity(0.08),
//                         ),
//                       ),
//                     ),
//                     SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.primaryTeal.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                       color:
//                                           AppTheme.primaryTeal.withOpacity(0.4),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       ScaleTransition(
//                                         scale: _pulseAnim,
//                                         child: const Icon(
//                                           Icons.auto_awesome_rounded,
//                                           color: AppTheme.primaryTeal,
//                                           size: 14,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       const Text(
//                                         'AI Diagnosis Engine',
//                                         style: TextStyle(
//                                           color: AppTheme.primaryTeal,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w700,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 14),
//                             const Text(
//                               'Prediksi\nDiagnosis Awal',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.w800,
//                                 height: 1.2,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Pilih gejala yang kamu rasakan',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.6),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               title: const Text(
//                 'Diagnosis AI',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//               titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
//               collapseMode: CollapseMode.pin,
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Urgency Level
//                   _buildSectionTitle('Tingkat Urgensi'),
//                   const SizedBox(height: 12),
//                   _buildUrgencySelector(),

//                   const SizedBox(height: 28),

//                   // Symptom Selection
//                   _buildSectionTitle('Pilih Gejala'),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${_selectedSymptoms.length} gejala dipilih',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: AppTheme.primaryTeal,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   _buildSymptomGrid(),

//                   const SizedBox(height: 28),

//                   // Additional Info
//                   _buildSectionTitle('Informasi Tambahan'),
//                   const SizedBox(height: 12),
//                   _buildTextField(
//                     hint: 'Deskripsikan keluhan lebih detail...',
//                     maxLines: 4,
//                     icon: Icons.edit_note_rounded,
//                   ),

//                   const SizedBox(height: 16),

//                   // Age & Gender Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildTextField(
//                           hint: 'Usia',
//                           icon: Icons.cake_rounded,
//                           keyboardType: TextInputType.number,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildDropdown(),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 32),

//                   // Analyze Button
//                   _buildAnalyzeButton(),

//                   const SizedBox(height: 24),

//                   // Disclaimer
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: AppTheme.info.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                           color: AppTheme.info.withOpacity(0.2), width: 1),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.info_outline_rounded,
//                             color: AppTheme.info, size: 18),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'Hasil prediksi bukan pengganti diagnosis dokter. Selalu konsultasikan dengan tenaga medis.',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: AppTheme.info,
//                               fontWeight: FontWeight.w500,
//                               height: 1.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: Theme.of(context).textTheme.headlineMedium,
//     );
//   }

//   Widget _buildUrgencySelector() {
//     final urgencies = [
//       _Urgency('Ringan', Icons.sentiment_satisfied_rounded, AppTheme.success),
//       _Urgency('Sedang', Icons.sentiment_neutral_rounded, AppTheme.warning),
//       _Urgency('Berat', Icons.sentiment_very_dissatisfied_rounded, AppTheme.danger),
//     ];

//     return Row(
//       children: urgencies.asMap().entries.map((entry) {
//         final i = entry.key;
//         final u = entry.value;
//         final isSelected = _selectedUrgency == i;
//         return Expanded(
//           child: GestureDetector(
//             onTap: () => setState(() => _selectedUrgency = i),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: isSelected ? u.color.withOpacity(0.12) : Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: isSelected ? u.color : AppTheme.divider,
//                   width: isSelected ? 2 : 1.5,
//                 ),
//                 boxShadow: isSelected
//                     ? [
//                         BoxShadow(
//                           color: u.color.withOpacity(0.2),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         )
//                       ]
//                     : [],
//               ),
//               child: Column(
//                 children: [
//                   Icon(u.icon, color: isSelected ? u.color : AppTheme.textMuted, size: 26),
//                   const SizedBox(height: 6),
//                   Text(
//                     u.label,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? u.color : AppTheme.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSymptomGrid() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: _symptoms.map((s) {
//         final isSelected = _selectedSymptoms.contains(s.label);
//         return GestureDetector(
//           onTap: () => setState(() {
//             if (isSelected) {
//               _selectedSymptoms.remove(s.label);
//             } else {
//               _selectedSymptoms.add(s.label);
//             }
//           }),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: isSelected ? AppTheme.primaryNavy : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isSelected ? AppTheme.primaryNavy : AppTheme.divider,
//                 width: 1.5,
//               ),
//               boxShadow: isSelected ? AppTheme.cardShadow : [],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   s.icon,
//                   size: 14,
//                   color: isSelected ? AppTheme.primaryTeal : AppTheme.textMuted,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   s.label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color:
//                         isSelected ? Colors.white : AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildTextField({
//     required String hint,
//     int maxLines = 1,
//     IconData? icon,
//     TextInputType? keyboardType,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.divider, width: 1.5),
//       ),
//       child: TextField(
//         maxLines: maxLines,
//         keyboardType: keyboardType,
//         style: const TextStyle(
//           fontSize: 14,
//           color: AppTheme.textPrimary,
//           fontFamily: 'Poppins',
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(
//             color: AppTheme.textMuted,
//             fontSize: 13,
//             fontFamily: 'Poppins',
//           ),
//           prefixIcon: icon != null
//               ? Icon(icon, color: AppTheme.textMuted, size: 20)
//               : null,
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.divider, width: 1.5),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           hint: const Text(
//             'Jenis Kelamin',
//             style: TextStyle(
//               color: AppTheme.textMuted,
//               fontSize: 13,
//               fontFamily: 'Poppins',
//             ),
//           ),
//           isExpanded: true,
//           icon:
//               const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
//           items: const [
//             DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
//             DropdownMenuItem(value: 'P', child: Text('Perempuan')),
//           ],
//           onChanged: (_) {},
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalyzeButton() {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         width: double.infinity,
//         height: 58,
//         decoration: BoxDecoration(
//           gradient: AppTheme.primaryGradient,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: AppTheme.tealGlow,
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
//             SizedBox(width: 10),
//             Text(
//               'Analisis dengan AI',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Symptom {
//   final String label;
//   final IconData icon;
//   const _Symptom({required this.label, required this.icon});
// }

// class _Urgency {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _Urgency(this.label, this.icon, this.color);
// }

// // import 'package:flutter/material.dart';
// // import '../../services/api_service.dart';

// // class DiagnosisScreen extends StatefulWidget {
// //   const DiagnosisScreen({super.key});

// //   @override
// //   State<DiagnosisScreen> createState() => _DiagnosisScreenState();
// // }

// // class _DiagnosisScreenState extends State<DiagnosisScreen> {
// //   final TextEditingController controller = TextEditingController();

// //   List<String> symptoms = [];
// //   Map<String, dynamic>? result;
// //   bool isLoading = false;

// //   void addSymptom() {
// //     if (controller.text.isNotEmpty) {
// //       setState(() {
// //         symptoms.add(controller.text);
// //         controller.clear();
// //       });
// //     }
// //   }

// //   void predict() async {
// //     setState(() {
// //       isLoading = true;
// //       result = null;
// //     });

// //     try {
// //       final res = await ApiService.predict(symptoms);

// //       setState(() {
// //         result = res;
// //       });
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e")),
// //       );
// //     }

// //     setState(() {
// //       isLoading = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Diagnosa')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             // INPUT
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: controller,
// //                     decoration: const InputDecoration(
// //                       hintText: "Masukkan gejala (contoh: fever)",
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.add),
// //                   onPressed: addSymptom,
// //                 )
// //               ],
// //             ),

// //             const SizedBox(height: 10),

// //             // LIST GEJALA
// //             Wrap(
// //               spacing: 8,
// //               children: symptoms
// //                   .map((s) => Chip(
// //                         label: Text(s),
// //                         onDeleted: () {
// //                           setState(() => symptoms.remove(s));
// //                         },
// //                       ))
// //                   .toList(),
// //             ),

// //             const SizedBox(height: 20),

// //             // BUTTON
// //             ElevatedButton(
// //               onPressed: predict,
// //               child: const Text("Diagnosa Sekarang"),
// //             ),

// //             const SizedBox(height: 20),

// //             // LOADING
// //             if (isLoading) const CircularProgressIndicator(),

// //             // RESULT
// //             if (result != null) Expanded(child: buildResult()),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildResult() {
// //     final diagnosis = result!["diagnosis"];
// //     final urgency = result!["urgency"];

// //     final top = diagnosis["top_disease"];
// //     final predictions = diagnosis["predictions"];

// //     return ListView(
// //       children: [
// //         // TOP DISEASE
// //         Card(
// //           child: ListTile(
// //             title: Text("Penyakit Utama"),
// //             subtitle: Text(top),
// //           ),
// //         ),

// //         // URGENCY
// //         Card(
// //           child: ListTile(
// //             title: Text("Urgensi"),
// //             subtitle: Text(urgency["label"]),
// //             trailing: Text(urgency["emoji"] ?? ""),
// //           ),
// //         ),

// //         const SizedBox(height: 10),

// //         const Text("Top 3 Diagnosis:",
// //             style: TextStyle(fontWeight: FontWeight.bold)),

// //         ...predictions.map<Widget>((p) {
// //           return Card(
// //             child: ListTile(
// //               title: Text(p["disease"]),
// //               subtitle: Text(p["description"]),
// //               trailing: Text("${p["probability_rf"]}"),
// //             ),
// //           );
// //         }).toList()
// //       ],
// //     );
// //   }
// // }