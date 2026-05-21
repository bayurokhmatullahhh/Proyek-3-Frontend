// KODE BARU 20-04-2026

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;
  const ResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    // Sample result data - in real app this comes from ML backend
    const diagnosis = 'Hipertensi Primer';
    const confidence = 0.87;
    const urgency = 'Sedang';
    const urgencyColor = AppTheme.warning;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.primaryNavy,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            title: const Text(
              'Hasil Prediksi AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main result card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.navyGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        // Confidence circle
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: confidence,
                                strokeWidth: 10,
                                backgroundColor:
                                    Colors.white.withOpacity(0.1),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryTeal),
                                strokeCap: StrokeCap.round,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(confidence * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                  const Text(
                                    'Akurasi',
                                    style: TextStyle(
                                      color: AppTheme.primaryTeal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Prediksi Diagnosis',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          diagnosis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: urgencyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: urgencyColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: urgencyColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Urgensi: $urgency',
                                style: TextStyle(
                                  color: urgencyColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recommendations
                  _buildSection(
                    'Rekomendasi Penanganan',
                    Icons.medical_services_rounded,
                    AppTheme.primaryTeal,
                    const [
                      'Segera konsultasikan ke dokter spesialis jantung/penyakit dalam',
                      'Kurangi konsumsi garam dan makanan berlemak',
                      'Pantau tekanan darah secara rutin setiap hari',
                      'Olahraga ringan minimal 30 menit per hari',
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Risk Factors
                  _buildSection(
                    'Faktor Risiko Terdeteksi',
                    Icons.warning_rounded,
                    AppTheme.accentOrange,
                    const [
                      'Stres tinggi akibat aktivitas urban',
                      'Pola makan tidak teratur',
                      'Kurang aktivitas fisik',
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.save_alt_rounded, size: 18),
                          label: const Text('Simpan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            side: const BorderSide(
                                color: AppTheme.primaryTeal, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text('Konsultasi Dokter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ResultPage extends StatefulWidget {
//   final List<String> symptoms;

//   const ResultPage({super.key, required this.symptoms});

//   @override
//   State<ResultPage> createState() => _ResultPageState();
// }

// class _ResultPageState extends State<ResultPage> {
//   Map<String, dynamic>? data;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future fetchData() async {
//     final response = await http.post(
//       Uri.parse("http:// 10.35.69.137:8001/predict"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "symptoms": widget.symptoms,
//         "age": 25
//       }),
//     );

//     setState(() {
//       data = jsonDecode(response.body);
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final diagnosis = data!["diagnosis"];
//     final urgency = data!["urgency"];

//     return Scaffold(
//       body: Column(
//         children: [
//           // 🔥 HEADER
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0A84FF), Color(0xFF34C759)],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               children: [
//                 const Text("Hasil Diagnosis",
//                     style: TextStyle(color: Colors.white, fontSize: 22)),
//                 const SizedBox(height: 10),

//                 Text(
//                   diagnosis["top_disease"],
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 10),

//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     "${urgency["emoji"]} ${urgency["label"]}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 🔥 CONTENT
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: diagnosis["predictions"].length,
//               itemBuilder: (context, i) {
//                 final item = diagnosis["predictions"][i];

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black12, blurRadius: 8)
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item["disease"],
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),

//                       const SizedBox(height: 10),

//                       LinearProgressIndicator(
//                         value: item["probability_rf"],
//                         minHeight: 8,
//                         borderRadius: BorderRadius.circular(10),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(item["description"]),

//                       const SizedBox(height: 10),

//                       Wrap(
//                         children: (item["precautions"] as List)
//                             .map((p) => Container(
//                                   margin: const EdgeInsets.only(right: 8, bottom: 8),
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Text(p),
//                                 ))
//                             .toList(),
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }