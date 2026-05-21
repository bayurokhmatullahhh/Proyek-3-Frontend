import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

/// ============================================================
/// CHATBOT SERVICE — ELSA (Edukasi Layanan Sehat Aktif)
/// Powered by Google Gemini API via REST
///
/// Fix: Added debug logging, proper error handling, retry logic,
///      and correct Gemini API request format
/// ============================================================

class ChatbotService {
  /// ── Gemini API URLs ────────────────────────────────────────────
  /// Daftar model dari yang paling ringan → paling berat
  /// Jika satu kena rate limit (429), otomatis coba model lain
  static const List<String> _modelUrls = [
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
  ];

  /// Conversation history untuk multi-turn chat
  final List<Map<String, dynamic>> _conversationHistory = [];

  /// System prompt ELSA — aturan ketat health-only
  static const String _systemPrompt = '''
Kamu adalah ELSA (Edukasi Layanan Sehat Aktif), sebuah HealthBot AI yang dibuat oleh Bayu ganteng untuk memberikan edukasi dan informasi kesehatan kepada masyarakat Indonesia.

ATURAN KETAT YANG WAJIB DIPATUHI:

1. IDENTITAS:
   - Jika ditanya siapa kamu, jawab: "Saya ELSA – Edukasi Layanan Sehat Aktif. HealthBot yang dibuat oleh Bayu ganteng untuk memberikan edukasi dan informasi kesehatan kepada masyarakat."
   - Jangan pernah mengaku sebagai Google, Gemini, ChatGPT, atau AI lainnya.

2. BATASAN TOPIK — HANYA jawab yang berkaitan dengan:
   - Informasi penyakit, gejala, dan penanganan awal
   - Tips gaya hidup sehat, pola makan sehat, dan nutrisi
   - Informasi obat umum dan penjelasan istilah medis
   - Rekomendasi olahraga dan aktivitas fisik sehat
   - Lokasi dan informasi fasilitas kesehatan di Kabupaten Indramayu (Rumah Sakit, Puskesmas, Apotek, Klinik)
   - Pertolongan pertama (P3K) dan penanganan darurat ringan
   - Kesehatan mental dasar (stress management, tips tidur sehat)

3. PENOLAKAN TEGAS — Jika ditanya di luar topik kesehatan (politik, agama, SARA, entertainment, teknologi non-kesehatan, percintaan, dll):
   Jawab HANYA: "Maaf, saya hanya dapat membantu dengan informasi seputar kesehatan. Apakah ada keluhan kesehatan, info nutrisi, atau pola gaya hidup sehat yang ingin Anda ketahui?"

4. FASILITAS KESEHATAN:
   - Fokus pada fasilitas kesehatan di Kabupaten Indramayu, Jawa Barat
   - Beberapa fasilitas yang diketahui: RSUD Indramayu, RS Pertamina Balongan, Puskesmas Jatibarang, Puskesmas Haurgeulis, Puskesmas Sindang, Puskesmas Losarang, Apotek Kimia Farma Indramayu, Apotek K-24 Indramayu
   - Jika ditanya fasilitas kesehatan di luar Indramayu, jawab sopan bahwa fokus layanan untuk area Indramayu

5. FORMAT JAWABAN:
   - Gunakan Bahasa Indonesia yang ramah dan mudah dipahami
   - Gunakan emoji secukupnya untuk kesan friendly
   - Untuk rekomendasi multiple, gunakan bullet points atau numbering
   - Sertakan tips praktis yang bisa dilakukan mandiri
   - SELALU akhiri dengan disclaimer: "⚠️ Informasi ini bersifat edukatif dan bukan pengganti diagnosis medis profesional. Segera konsultasikan ke dokter atau tenaga medis jika keluhan berlanjut."

6. KUALITAS JAWABAN:
   - Berikan jawaban yang spesifik, akurat, dan berbasis pengetahuan medis dasar
   - Jika tidak yakin, sampaikan dengan jujur dan sarankan untuk verifikasi ke tenaga medis
   - Prioritaskan keselamatan pasien dalam setiap saran

7. JANGAN PERNAH:
   - Mendiagnosis penyakit secara pasti
   - Meresepkan obat dengan dosis spesifik
   - Menyarankan menghentikan pengobatan dokter
   - Menjawab pertanyaan di luar konteks kesehatan
''';

  /// ══════════════════════════════════════════════════════════════
  /// Kirim pesan dan dapatkan respons dari Gemini
  /// ══════════════════════════════════════════════════════════════
  Future<String> sendMessage(String userMessage) async {
    final apiKey = AppConfig.geminiApiKey;

    // ── Guard: API key belum diset ─────────────────────────────
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      print('[ELSA] ⚠️ API Key belum diset, menggunakan mode offline');
      return _getOfflineResponse(userMessage);
    }

    // ── Tambahkan pesan user ke history ────────────────────────
    _conversationHistory.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    // ── Coba semua model (auto-fallback jika 429/404) ─────────
    for (int i = 0; i < _modelUrls.length; i++) {
      final modelUrl = _modelUrls[i];
      final modelName = modelUrl.split('/models/').last.split(':').first;
      print('[ELSA] 🔄 Mencoba model ${i + 1}/${_modelUrls.length}: $modelName');

      final result = await _callGeminiApi(apiKey, modelUrl);
      if (result != null) return result;

      // Jika bukan model terakhir, tunggu sebentar sebelum retry
      if (i < _modelUrls.length - 1) {
        print('[ELSA] ⏳ Menunggu 1 detik sebelum coba model berikutnya...');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // ── Semua model gagal → coba simplified request (tanpa systemInstruction) ──
    print('[ELSA] 🔄 Semua model gagal, mencoba simplified request...');
    for (int i = 0; i < _modelUrls.length; i++) {
      final result = await _callGeminiApiSimple(apiKey, _modelUrls[i]);
      if (result != null) return result;

      if (i < _modelUrls.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // ── Semua gagal total → rollback history ──────────────────
    _conversationHistory.removeLast();
    return 'Maaf, layanan AI sedang sibuk (rate limit). '
        'Silakan tunggu 1-2 menit dan coba lagi. ⏳\n\n'
        'Tips: Jika terus terjadi, buat API Key baru di:\n'
        'https://aistudio.google.com/apikey';
  }

  /// ══════════════════════════════════════════════════════════════
  /// Core API call ke Gemini — returns null jika gagal
  /// ══════════════════════════════════════════════════════════════
  Future<String?> _callGeminiApi(String apiKey, String modelUrl) async {
    try {
      final url = '$modelUrl?key=$apiKey';
      print('[ELSA] 📡 Mengirim request ke: ${modelUrl.split('/').last}');

      // ── Build request body ──────────────────────────────────
      final requestBody = {
        'contents': _conversationHistory,
        'systemInstruction': {
          'role': 'user',
          'parts': [
            {'text': _systemPrompt}
          ],
        },
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
          'topP': 0.95,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
        ],
      };

      final encodedBody = jsonEncode(requestBody);
      print('[ELSA] 📦 Request body length: ${encodedBody.length} chars');

      // ── Kirim HTTP POST ─────────────────────────────────────
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: encodedBody,
          )
          .timeout(AppConfig.chatbotTimeout);

      print('[ELSA] 📥 Status code: ${response.statusCode}');

      // ── Handle response ─────────────────────────────────────
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        if (text.isEmpty) {
          // Cek apakah ada block reason dari safety filter
          final blockReason =
              data['candidates']?[0]?['finishReason']?.toString() ?? '';
          final promptFeedback =
              data['promptFeedback']?['blockReason']?.toString() ?? '';
          print('[ELSA] ⚠️ Empty response. finishReason=$blockReason, '
              'promptFeedback=$promptFeedback');

          if (blockReason == 'SAFETY' || promptFeedback.isNotEmpty) {
            return 'Maaf, pertanyaan Anda tidak dapat diproses karena alasan keamanan konten. '
                'Silakan coba dengan pertanyaan lain seputar kesehatan. 🏥';
          }

          _conversationHistory.removeLast();
          return 'Maaf, saya tidak dapat memproses permintaan Anda saat ini. Silakan coba lagi.';
        }

        // ── Sukses! Simpan respons bot ke history ─────────────
        _conversationHistory.add({
          'role': 'model',
          'parts': [
            {'text': text}
          ],
        });

        print('[ELSA] ✅ Berhasil mendapat respons (${text.length} chars)');
        return text;
      } else {
        // ── Non-200: Log detail error ─────────────────────────
        print('[ELSA] ❌ Error ${response.statusCode}');
        print('[ELSA] ❌ Response body: ${response.body}');

        // Parse error message dari Gemini
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error']?['message']?.toString() ?? '';
          final errorStatus =
              errorData['error']?['status']?.toString() ?? '';
          print('[ELSA] ❌ Error detail: $errorStatus - $errorMsg');

          // Handle specific error codes
          if (response.statusCode == 400) {
            print('[ELSA] 💡 400 Bad Request — format request mungkin salah');
            // Coba tanpa systemInstruction (beberapa versi API tidak support)
            return await _callGeminiApiSimple(apiKey, modelUrl);
          }

          if (response.statusCode == 403) {
            _conversationHistory.removeLast();
            return 'API Key tidak valid atau belum diaktifkan. '
                'Pastikan API Key Gemini sudah benar dan aktif di Google AI Studio. 🔑';
          }

          if (response.statusCode == 429) {
            print('[ELSA] 💡 429 Rate limit — mencoba model lain...');
            return null; // trigger fallback ke model berikutnya
          }

          if (response.statusCode == 404) {
            print('[ELSA] 💡 404 — Model tidak ditemukan, coba fallback');
            return null; // akan trigger fallback
          }
        } catch (parseErr) {
          print('[ELSA] ⚠️ Gagal parse error response: $parseErr');
        }

        return null; // trigger fallback
      }
    } on TimeoutException {
      print('[ELSA] ⏰ Request timeout');
      return null;
    } catch (e) {
      print('[ELSA] 🔥 Exception: $e');
      return null;
    }
  }

  /// ══════════════════════════════════════════════════════════════
  /// Simplified API call — tanpa systemInstruction
  /// Fallback jika format systemInstruction ditolak oleh API
  /// ══════════════════════════════════════════════════════════════
  Future<String?> _callGeminiApiSimple(String apiKey, String modelUrl) async {
    try {
      print('[ELSA] 🔄 Mencoba request simplified (tanpa systemInstruction)...');

      // Inject system prompt sebagai pesan pertama dalam contents
      final contentsWithSystem = <Map<String, dynamic>>[
        {
          'role': 'user',
          'parts': [
            {'text': _systemPrompt}
          ],
        },
        {
          'role': 'model',
          'parts': [
            {
              'text':
                  'Baik, saya ELSA (Edukasi Layanan Sehat Aktif). Saya akan mengikuti semua aturan yang diberikan. Saya siap membantu dengan informasi kesehatan! 🏥'
            }
          ],
        },
        ..._conversationHistory,
      ];

      final requestBody = {
        'contents': contentsWithSystem,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
          'topP': 0.95,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
        ],
      };

      final response = await http
          .post(
            Uri.parse('$modelUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(AppConfig.chatbotTimeout);

      print('[ELSA] 📥 Simplified request status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        if (text.isNotEmpty) {
          _conversationHistory.add({
            'role': 'model',
            'parts': [
              {'text': text}
            ],
          });
          print('[ELSA] ✅ Simplified request berhasil! (${text.length} chars)');
          return text;
        }
      } else {
        print('[ELSA] ❌ Simplified request gagal: ${response.statusCode}');
        print('[ELSA] ❌ Body: ${response.body}');
      }

      return null;
    } catch (e) {
      print('[ELSA] 🔥 Simplified request exception: $e');
      return null;
    }
  }

  /// Respons offline (fallback tanpa API key)
  String _getOfflineResponse(String message) {
    final msg = message.toLowerCase().trim();

    // Identity
    if (msg.contains('siapa kamu') ||
        msg.contains('siapa anda') ||
        msg.contains('kamu siapa')) {
      return 'Saya ELSA – Edukasi Layanan Sehat Aktif 🏥\n\n'
          'HealthBot yang dibuat oleh Bayu ganteng untuk memberikan edukasi '
          'dan informasi kesehatan kepada masyarakat.\n\n'
          'Saya siap membantu Anda dengan informasi seputar kesehatan! 💪';
    }

    // Health topic detection
    final healthKeywords = [
      'sakit', 'demam', 'batuk', 'flu', 'pusing', 'mual', 'diare', 'gatal',
      'alergi', 'obat', 'vitamin', 'diet', 'nutrisi', 'olahraga', 'tidur',
      'stress', 'rumah sakit', 'puskesmas', 'apotek', 'dokter', 'klinik',
      'gejala', 'penyakit', 'sehat', 'kesehatan', 'makan', 'gizi',
      'tekanan darah', 'diabetes', 'kolesterol', 'jantung', 'asma',
      'infeksi', 'luka', 'patah', 'nyeri', 'radang', 'muntah',
      'p3k', 'pertolongan', 'rs', 'indramayu', 'vaksin', 'imunisasi',
    ];

    final isHealthTopic = healthKeywords.any((k) => msg.contains(k));

    if (!isHealthTopic) {
      return 'Maaf, saya hanya dapat membantu dengan informasi seputar kesehatan. 🏥\n\n'
          'Apakah ada keluhan kesehatan, info nutrisi, atau pola gaya hidup sehat '
          'yang ingin Anda ketahui?';
    }

    // Faskes Indramayu
    if (msg.contains('rumah sakit') ||
        msg.contains('rs') ||
        msg.contains('puskesmas') ||
        msg.contains('apotek') ||
        msg.contains('klinik')) {
      return '🏥 **Fasilitas Kesehatan di Indramayu:**\n\n'
          '🔹 **RSUD Kabupaten Indramayu** - Jl. Murah Nara No.1\n'
          '🔹 **RS Pertamina Balongan** - Kec. Balongan\n'
          '🔹 **Puskesmas Jatibarang** - Kec. Jatibarang\n'
          '🔹 **Puskesmas Haurgeulis** - Kec. Haurgeulis\n'
          '🔹 **Apotek Kimia Farma** - Jl. Jend. Sudirman\n'
          '🔹 **Apotek K-24** - Jl. Siliwangi\n\n'
          '📞 Untuk info lebih lanjut, hubungi fasilitas kesehatan terkait.\n\n'
          '⚠️ Informasi ini bersifat edukatif dan bukan pengganti diagnosis medis profesional.';
    }

    // Default health response
    return '🩺 Terima kasih atas pertanyaannya!\n\n'
        'Untuk mendapatkan jawaban yang lebih akurat dan personal, '
        'silakan konfigurasikan API Key Gemini di pengaturan aplikasi.\n\n'
        'Sementara itu, beberapa tips umum:\n'
        '• Istirahat yang cukup (7-8 jam/hari)\n'
        '• Minum air putih minimal 8 gelas/hari\n'
        '• Konsumsi makanan bergizi seimbang\n'
        '• Olahraga rutin minimal 30 menit/hari\n\n'
        '⚠️ Jika keluhan berlanjut, segera konsultasikan ke dokter atau '
        'kunjungi fasilitas kesehatan terdekat di Indramayu.';
  }

  /// Reset conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Cek apakah topik termasuk kesehatan (untuk testing)
  static bool isHealthTopic(String message) {
    final msg = message.toLowerCase().trim();
    final healthKeywords = [
      'sakit', 'demam', 'batuk', 'flu', 'pusing', 'mual', 'diare', 'gatal',
      'alergi', 'obat', 'vitamin', 'diet', 'nutrisi', 'olahraga', 'tidur',
      'stress', 'rumah sakit', 'puskesmas', 'apotek', 'dokter', 'klinik',
      'gejala', 'penyakit', 'sehat', 'kesehatan', 'makan', 'gizi',
      'tekanan darah', 'diabetes', 'kolesterol', 'jantung', 'asma',
      'infeksi', 'luka', 'patah', 'nyeri', 'radang', 'muntah',
      'p3k', 'pertolongan', 'rs', 'indramayu', 'vaksin', 'imunisasi',
      'siapa kamu', 'siapa anda',
    ];
    return healthKeywords.any((k) => msg.contains(k));
  }

  /// Welcome message ELSA
  static String get welcomeMessage =>
      'Halo! 👋 Saya **ELSA** (Edukasi Layanan Sehat Aktif)\n\n'
      'Saya siap membantu Anda dengan informasi seputar:\n'
      '🩺 Kesehatan & Penyakit\n'
      '🥗 Nutrisi & Gaya Hidup Sehat\n'
      '🏥 Fasilitas Kesehatan di Indramayu\n'
      '💊 Info Obat & Istilah Medis\n'
      '🏃 Tips Olahraga Sehat\n\n'
      'Silakan tanyakan apa saja seputar kesehatan! 😊';

  /// Quick suggestion topics
  static List<String> get quickSuggestions => [
        '🩺 Gejala demam tinggi',
        '🥗 Tips diet sehat',
        '🏥 RS di Indramayu',
        '💊 Info vitamin',
        '🏃 Olahraga untuk pemula',
        '😴 Tips tidur berkualitas',
      ];
}
