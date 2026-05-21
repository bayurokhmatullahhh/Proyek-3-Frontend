import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import 'auth_service.dart';

/// ApiService — Diagnosis, History, Profile
/// Disesuaikan dengan:
/// - Laravel route: POST /api/diagnosis/assess
/// - FastAPI ML response: { diagnosis: { predictions, top_disease }, urgency: {...} }

class ApiService {

  // ── DIAGNOSIS ASSESS (via Laravel → FastAPI) ──────────────────
  /// Laravel di /api/diagnosis/assess akan forward ke FastAPI /predict
  /// Return: DiagnosisResult model
  static Future<DiagnosisResult> assess({
    required List<String> symptoms,  // dalam format snake_case: ["itching", "skin_rash"]
    required int age,
    String? gender,
  }) async {
    final res = await _post(
      AppConfig.diagnosisAssessEndpoint,
      body: {
        'symptoms': symptoms,
        'age':      age,
        if (gender != null) 'gender': gender,
      },
    );
    return DiagnosisResult.fromJson(res);
  }

  // ── CALL ML FASTAPI LANGSUNG (fallback jika Laravel forward belum ada) ──
  /// Panggil FastAPI langsung dari Flutter
  static Future<DiagnosisResult> predictDirect({
    required List<String> symptoms,
    required int age,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.mlBaseUrl}${AppConfig.mlPredictEndpoint}'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'symptoms': symptoms, 'age': age}),
      ).timeout(AppConfig.requestTimeout);

      final data = _decode(res.body);
      if (data == null) throw ApiException('Respons ML tidak valid.');
      if (res.statusCode != 200) {
        throw ApiException(data['error']?.toString() ?? 'ML error.');
      }
      return DiagnosisResult.fromJson(data);
    } on ApiException { rethrow; }
    on Exception catch (e) { throw ApiException(_connErr(e)); }
  }

  // ── DIAGNOSIS HISTORY ─────────────────────────────────────────
  static Future<List<DiagnosisHistoryItem>> getDiagnosisHistory() async {
    final res = await _get(AppConfig.diagnosisHistoryEndpoint);
    final list = res['data'] ?? res['history'] ?? [];
    return (list as List)
        .map((e) => DiagnosisHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── SYMPTOM LIST dari Laravel ─────────────────────────────────
  static Future<List<String>> getSymptoms() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.symptomsEndpoint}'),
        headers: {'Accept': 'application/json'},
      ).timeout(AppConfig.requestTimeout);
      final data = _decode(res.body);
      if (data == null) return [];
      final list = data['data'] ?? data['symptoms'] ?? [];
      return List<String>.from(list as List);
    } catch (_) { return []; }
  }

  // ── PATIENT PROFILE ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await _get(AppConfig.profileEndpoint);
      return res['data'] ?? res['patient'] ?? res;
    } on ApiException { return null; }
  }

  static Future<String?> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      await _put(AppConfig.profileEndpoint, body: {
        'name':   name,
        if (phone != null)       'phone':         phone,
        if (gender != null)      'gender':        gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      });
      await AuthService.fetchUserProfile();
      return null;
    } on ApiException catch (e) { return e.message; }
  }

  // ── PRIVATE HTTP HELPERS ──────────────────────────────────────
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await AuthService.authHeaders(),
      ).timeout(AppConfig.requestTimeout);
      return _handle(res);
    } on ApiException { rethrow; }
    on Exception catch (e) { throw ApiException(_connErr(e)); }
  }

  static Future<Map<String, dynamic>> _post(
      String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await AuthService.authHeaders(),
        body: jsonEncode(body),
      ).timeout(AppConfig.requestTimeout);
      return _handle(res);
    } on ApiException { rethrow; }
    on Exception catch (e) { throw ApiException(_connErr(e)); }
  }

  static Future<Map<String, dynamic>> _put(
      String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final res = await http.put(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await AuthService.authHeaders(),
        body: jsonEncode(body),
      ).timeout(AppConfig.requestTimeout);
      return _handle(res);
    } on ApiException { rethrow; }
    on Exception catch (e) { throw ApiException(_connErr(e)); }
  }

  static Map<String, dynamic> _handle(http.Response res) {
    final data = _decode(res.body);
    if (data == null) throw ApiException('Respons tidak valid (bukan JSON).');
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    if (res.statusCode == 401) {
      throw ApiException('Sesi habis. Silakan login ulang.', isUnauth: true);
    }
    if (res.statusCode == 422) {
      final errors = data['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final first = errors.values.first;
        throw ApiException((first is List && first.isNotEmpty)
            ? first.first.toString() : 'Validasi gagal.');
      }
    }
    throw ApiException(
        data['message']?.toString() ?? 'Error ${res.statusCode}.');
  }

  static Map<String, dynamic>? _decode(String body) {
    try { return jsonDecode(body) as Map<String, dynamic>; }
    catch (_) { return null; }
  }

  static String _connErr(Exception e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('refused')) {
      return 'Server tidak terjangkau. Pastikan Laragon & FastAPI aktif.';
    }
    if (s.contains('timeout')) return 'Koneksi timeout.';
    return 'Error: $e';
  }
}

// ══════════════════════════════════════════════════════════════════
// MODEL CLASSES — sesuai response FastAPI main.py lo
// ══════════════════════════════════════════════════════════════════

/// Satu prediksi penyakit (ada 3: rank 1, 2, 3)
class DiseasePrediction {
  final int rank;
  final String disease;
  final double probabilityRf;
  final double probabilityNb;
  final String description;
  final List<String> precautions;

  const DiseasePrediction({
    required this.rank,
    required this.disease,
    required this.probabilityRf,
    required this.probabilityNb,
    required this.description,
    required this.precautions,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> j) {
    return DiseasePrediction(
      rank:           (j['rank'] as num?)?.toInt()          ?? 0,
      disease:        j['disease']?.toString()              ?? '',
      probabilityRf:  (j['probability_rf'] as num?)?.toDouble() ?? 0.0,
      probabilityNb:  (j['probability_nb'] as num?)?.toDouble() ?? 0.0,
      description:    j['description']?.toString()          ?? '',
      precautions:    _toList(j['precautions']),
    );
  }

  static List<String> _toList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

/// Urgency dari FastAPI: { level, label, description, emoji, color, confidence, action }
class UrgencyInfo {
  final String level;       // 'Normal' | 'Semi' | 'Urgent'
  final String label;
  final String description;
  final String emoji;
  final String color;       // hex color, e.g. '#FF3B30'
  final double confidence;
  final String action;

  const UrgencyInfo({
    required this.level,
    required this.label,
    required this.description,
    required this.emoji,
    required this.color,
    required this.confidence,
    required this.action,
  });

  factory UrgencyInfo.fromJson(Map<String, dynamic> j) {
    return UrgencyInfo(
      level:       j['level']?.toString()       ?? 'Normal',
      label:       j['label']?.toString()       ?? 'Normal',
      description: j['description']?.toString() ?? '',
      emoji:       j['emoji']?.toString()       ?? '✅',
      color:       j['color']?.toString()       ?? '#34C759',
      confidence:  (j['confidence'] as num?)?.toDouble() ?? 0.0,
      action:      j['action']?.toString()      ?? '',
    );
  }

  /// Urgency level → 0/1/2 untuk UI color
  int get levelIndex {
    switch (level.toLowerCase()) {
      case 'urgent': return 2;
      case 'semi':   return 1;
      default:       return 0;
    }
  }
}

/// Full result dari ML:
/// {
///   diagnosis: { predictions: [...], top_disease, symptoms_matched, lifestyle_recommendation },
///   urgency:   { level, label, description, emoji, color, confidence, action }
/// }
class DiagnosisResult {
  final List<DiseasePrediction> predictions;
  final String topDisease;
  final List<String> symptomsMatched;
  final List<String> lifestyleRecommendation;
  final UrgencyInfo urgency;

  const DiagnosisResult({
    required this.predictions,
    required this.topDisease,
    required this.symptomsMatched,
    required this.lifestyleRecommendation,
    required this.urgency,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> j) {
    // Support dua format: langsung dari FastAPI atau wrapped dari Laravel
    final diagMap = j['diagnosis'] as Map<String, dynamic>? ?? j;
    //final urgMap  = j['urgency']   as Map<String, dynamic>? ?? {};
    Map<String, dynamic> urgMap;

if (j['urgency'] != null) {
  urgMap = j['urgency'];
} else {
  // 🔥 fallback dari FastAPI langsung
  urgMap = {
    'level': j['final_urgency'] ?? 'Normal',
    'confidence': j['confidence'] ?? 0.0,
    'label': j['final_urgency'] ?? 'Normal',
    'description': '',
    'emoji': '⚠️',
    'color': '#FF3B30',
    'action': '',
  };
}
    final predList = diagMap['predictions'] as List? ?? [];

    return DiagnosisResult(
      predictions: predList
          .map((e) => DiseasePrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      topDisease:  diagMap['top_disease']?.toString() ?? '',
      symptomsMatched: _toList(diagMap['symptoms_matched']),
      lifestyleRecommendation: _toList(diagMap['lifestyle_recommendation']),
      urgency: urgMap.isNotEmpty
          ? UrgencyInfo.fromJson(urgMap)
          : UrgencyInfo(
              level: 'Normal', label: 'Normal', description: '',
              emoji: '✅', color: '#34C759', confidence: 0.0,
              action: 'Monitor kondisi',
            ),
    );
  }

  static List<String> _toList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  /// Top prediction (rank 1)
  DiseasePrediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;

  /// Confidence dalam persen
  int get confidencePercent =>
      (urgency.confidence * 100).round();
}

/// Item di riwayat diagnosis
class DiagnosisHistoryItem {
  final String id;
  final String topDisease;
  final String urgencyLevel;
  final String urgencyColor;
  final String date;
  final double confidence;

  const DiagnosisHistoryItem({
    required this.id,
    required this.topDisease,
    required this.urgencyLevel,
    required this.urgencyColor,
    required this.date,
    required this.confidence,
  });

  factory DiagnosisHistoryItem.fromJson(Map<String, dynamic> j) {
    return DiagnosisHistoryItem(
      id:           j['id']?.toString()           ?? '',
      topDisease:   j['top_disease']?.toString()  ?? j['diagnosis']?.toString() ?? '',
      urgencyLevel: j['urgency_level']?.toString() ?? j['urgency']?.toString()  ?? 'Normal',
      urgencyColor: j['urgency_color']?.toString() ?? '#34C759',
      date:         j['created_at']?.toString()   ?? '',
      confidence:   (j['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final bool isUnauth;
  const ApiException(this.message, {this.isUnauth = false});
  @override String toString() => message;
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class ApiService {
//   static const String baseUrl = "http://10.0.164.56:8000"; // ganti kalau beda

//   static Future<Map<String, dynamic>> predict(List<String> symptoms) async {
//   final url = "$baseUrl/predict";

//   print("URL: $url");
//   print("BODY: $symptoms");

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "symptoms": symptoms,
//       "age": 20
//     }),
//   );

//   print("STATUS: ${response.statusCode}");
//   print("RESPONSE: ${response.body}");

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception("Failed: ${response.body}");
//   }
// }
// }