import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../core/app_config.dart';

/// AuthService — connect ke Laravel Sanctum
class AuthService {

  // ── LOGIN ─────────────────────────────────────────────────────
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
        headers: _baseHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(AppConfig.requestTimeout);

      final data = _decode(res.body);
      if (data == null) return 'Respons server tidak valid.';

      if (res.statusCode == 200 && data['success'] == true) {
        final token = data['token']?.toString() ?? '';
        final user  = data['user'] as Map<String, dynamic>? ?? {};
        await _saveSession(token, user);
        return null;
      }

      return data['message']?.toString() ?? 'Email atau password salah.';
    } on Exception catch (e) {
      return _handleException(e);
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────
  static Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
    String? dateOfBirth,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.registerEndpoint}'),
        headers: _baseHeaders(),
        body: jsonEncode({
          'name':                  name,
          'email':                 email,
          'phone':                 phone,
          'password':              password,
          'password_confirmation': password,
          'role':                  'patient',
          'gender':                gender,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        }),
      ).timeout(AppConfig.requestTimeout);

      final data = _decode(res.body);
      if (data == null) return 'Respons server tidak valid.';

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          data['success'] == true) {
        return null;
      }

      if (res.statusCode == 422) {
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          return (first is List && first.isNotEmpty)
              ? first.first.toString()
              : 'Validasi gagal.';
        }
      }

      return data['message']?.toString() ?? 'Registrasi gagal.';
    } on Exception catch (e) {
      return _handleException(e);
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}${AppConfig.logoutEndpoint}'),
          headers: await authHeaders(),
        ).timeout(AppConfig.requestTimeout);
      }
    } catch (_) {
    } finally {
      await _clearSession();
    }
  }

  // ── FETCH PROFIL DARI SERVER ──────────────────────────────────
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.meEndpoint}'),
        headers: await authHeaders(),
      ).timeout(AppConfig.requestTimeout);

      if (res.statusCode == 200) {
        final data = _decode(res.body);
        if (data == null) return null;

        final user = data['user'] as Map<String, dynamic>? ?? data;
        final prefs = await SharedPreferences.getInstance();
        
        // Pertahankan foto profil lokal jika server belum mendukung
        final existingRaw = prefs.getString(AppConfig.keyUser);
        if (existingRaw != null && existingRaw.isNotEmpty) {
          try {
            final existing = Map<String, dynamic>.from(jsonDecode(existingRaw));
            if (existing['profile_image'] != null && user['profile_image'] == null) {
              user['profile_image'] = existing['profile_image'];
            }
          } catch (_) {}
        }
        
        await prefs.setString(AppConfig.keyUser, jsonEncode(user));
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── UPDATE PROFIL ─────────────────────────────────────────────
  /// PUT /api/patient/profile
  /// Return null = sukses, String = pesan error
  static Future<String?> updateUserData(Map<String, dynamic> data) async {
    // 1. Simpan lokal dulu — UI langsung update tanpa nunggu server
    final prefs    = await SharedPreferences.getInstance();
    final existing = await getUserData();
    final merged   = {...existing, ...data};
    await prefs.setString(AppConfig.keyUser, jsonEncode(merged));

    // 2. Sinkron ke server
    try {
      final res = await http.put(
        // ✅ Sesuai api.php: PUT /api/patient/profile
        Uri.parse('${AppConfig.baseUrl}${AppConfig.profileEndpoint}'),
        headers: await authHeaders(),
        body: jsonEncode({
          'name':   data['name'],
          'email':  data['email'],
          'phone':  data['phone'],
          'gender': data['gender'],
        }),
      ).timeout(AppConfig.requestTimeout);

      final body = _decode(res.body);

      if (res.statusCode == 200 && body?['success'] == true) {
        // Sinkronkan lokal dengan fresh data dari server
        final freshUser = body!['user'] as Map<String, dynamic>?;
        if (freshUser != null) {
          if (data['profile_image'] != null && freshUser['profile_image'] == null) {
            freshUser['profile_image'] = data['profile_image'];
          }
          await prefs.setString(AppConfig.keyUser, jsonEncode(freshUser));
        }
        return null; // sukses
      }

      if (res.statusCode == 422) {
        final errors = body?['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          return (first is List && first.isNotEmpty)
              ? first.first.toString()
              : 'Validasi gagal.';
        }
      }

      return body?['message']?.toString() ?? 'Gagal memperbarui profil.';

    } on Exception catch (e) {
      // Lokal sudah tersimpan, tidak perlu throw
      debugPrint('[AuthService] updateUserData error: $e');
      return null;
    }
  }

  // ── GANTI PASSWORD ────────────────────────────────────────────
  /// PUT /api/patient/change-password
  /// Return null = sukses, String = pesan error
  static Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await http.put(
        // ✅ Endpoint baru yang sudah ditambah di api.php
        Uri.parse('${AppConfig.baseUrl}/api/patient/change-password'),
        headers: await authHeaders(),
        body: jsonEncode({
          'current_password':      oldPassword,
          'password':              newPassword,
          'password_confirmation': newPassword,
        }),
      ).timeout(AppConfig.requestTimeout);

      final data = _decode(res.body);

      if (res.statusCode == 200 && data?['success'] == true) {
        return null; // sukses
      }

      if (res.statusCode == 422) {
        final errors = data?['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          return (first is List && first.isNotEmpty)
              ? first.first.toString()
              : 'Validasi gagal.';
        }
      }

      // 401 = password lama salah
      if (res.statusCode == 401) {
        return data?['message']?.toString() ?? 'Password lama salah.';
      }

      return data?['message']?.toString() ?? 'Gagal mengganti password.';

    } on Exception catch (e) {
      return _handleException(e);
    }
  }

  // ── HELPERS PUBLIK ────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.keyLoggedIn) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(AppConfig.keyToken);
    return (t != null && t.isNotEmpty) ? t : null;
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConfig.keyUser);
    if (raw == null || raw.isEmpty) return {};
    try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); }
    catch (_) { return {}; }
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── PRIVATE ───────────────────────────────────────────────────
  static Map<String, String> _baseHeaders() => {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
  };

  static Future<void> _saveSession(
      String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyToken,  token);
    await prefs.setString(AppConfig.keyUser,   jsonEncode(user));
    await prefs.setBool(AppConfig.keyLoggedIn, true);
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keyToken);
    await prefs.remove(AppConfig.keyUser);
    await prefs.setBool(AppConfig.keyLoggedIn, false);
  }

  static Map<String, dynamic>? _decode(String body) {
    try { return jsonDecode(body) as Map<String, dynamic>; }
    catch (_) { return null; }
  }

  static String _handleException(Exception e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('connection refused')) {
      return 'Tidak dapat terhubung ke server. Pastikan server aktif.';
    }
    if (s.contains('timeout')) return 'Koneksi timeout. Cek jaringan kamu.';
    return 'Error: ${e.toString()}';
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import '../core/app_config.dart';

// /// AuthService — connect ke Laravel Sanctum
// /// Disesuaikan dengan struktur response AuthController lo:
// /// { success: bool, token: string, user: { ...user, patient: {...} } }

// class AuthService {

//   // ── LOGIN ─────────────────────────────────────────────────────
//   /// Return null = sukses, String = pesan error
//   static Future<String?> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final res = await http.post(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
//         headers: _baseHeaders(),
//         body: jsonEncode({'email': email, 'password': password}),
//       ).timeout(AppConfig.requestTimeout);

//       final data = _decode(res.body);
//       if (data == null) return 'Respons server tidak valid.';

//       // Laravel return { success: true, token: "...", user: {...} }
//       if (res.statusCode == 200 && data['success'] == true) {
//         final token = data['token']?.toString() ?? '';
//         final user  = data['user']  as Map<String, dynamic>? ?? {};

//         await _saveSession(token, user);
//         return null; // null = sukses
//       }

//       return data['message']?.toString() ?? 'Email atau password salah.';

//     } on Exception catch (e) {
//       return _handleException(e);
//     }
//   }

//   // ── REGISTER ──────────────────────────────────────────────────
//   /// Return null = sukses, String = pesan error
//   static Future<String?> register({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String gender,    // 'male' | 'female' | 'other'
//     String? dateOfBirth,       // format: 'yyyy-MM-dd', opsional
//   }) async {
//     try {
//       final res = await http.post(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.registerEndpoint}'),
//         headers: _baseHeaders(),
//         body: jsonEncode({
//           'name':                  name,
//           'email':                 email,
//           'phone':                 phone,
//           'password':              password,
//           'password_confirmation': password,
//           'role':                  'patient',
//           'gender':                gender,
//           if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
//         }),
//       ).timeout(AppConfig.requestTimeout);

//       final data = _decode(res.body);
//       if (data == null) return 'Respons server tidak valid.';

//       // Sukses: status 201 + success: true
//       if ((res.statusCode == 200 || res.statusCode == 201) &&
//           data['success'] == true) {
//         return null;
//       }

//       // Validasi Laravel (422) — ambil error pertama
//       if (res.statusCode == 422) {
//         final errors = data['errors'] as Map<String, dynamic>?;
//         if (errors != null && errors.isNotEmpty) {
//           final first = errors.values.first;
//           return (first is List && first.isNotEmpty)
//               ? first.first.toString()
//               : 'Validasi gagal.';
//         }
//       }

//       return data['message']?.toString() ?? 'Registrasi gagal.';

//     } on Exception catch (e) {
//       return _handleException(e);
//     }
//   }

//   // ── LOGOUT ────────────────────────────────────────────────────
//   static Future<void> logout() async {
//     try {
//       final token = await getToken();
//       if (token != null) {
//         await http.post(
//           Uri.parse('${AppConfig.baseUrl}${AppConfig.logoutEndpoint}'),
//           headers: await authHeaders(),
//         ).timeout(AppConfig.requestTimeout);
//       }
//     } catch (_) {
//       // Gagal di server tetap clear lokal
//     } finally {
//       await _clearSession();
//     }
//   }

//   // ── FETCH PROFIL DARI SERVER ──────────────────────────────────
//   static Future<Map<String, dynamic>?> fetchUserProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.meEndpoint}'),
//         headers: await authHeaders(),
//       ).timeout(AppConfig.requestTimeout);

//       if (res.statusCode == 200) {
//         final data = _decode(res.body);
//         if (data == null) return null;

//         // /api/auth/me return { user: {...} }
//         final user = data['user'] as Map<String, dynamic>? ?? data;
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(AppConfig.keyUser, jsonEncode(user));
//         return user;
//       }
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }

//   // ── UPDATE PROFIL ─────────────────────────────────────────────
//   /// Update nama, email, phone, gender — return null = sukses, String = error
//   static Future<String?> updateUserData(Map<String, dynamic> data) async {
//     // 1. Simpan lokal dulu supaya UI langsung update
//     final prefs = await SharedPreferences.getInstance();
//     final existing = await getUserData();
//     final merged   = {...existing, ...data};
//     await prefs.setString(AppConfig.keyUser, jsonEncode(merged));

//     // 2. Kirim ke server
//     try {
//       final res = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/api/profile'),
//         headers: await authHeaders(),
//         body: jsonEncode({
//           'name':   data['name'],
//           'email':  data['email'],
//           'phone':  data['phone'],
//           'gender': data['gender'],
//         }),
//       ).timeout(AppConfig.requestTimeout);

//       final body = _decode(res.body);

//       if (res.statusCode == 200 && body?['success'] == true) {
//         // Jika server return user terbaru, sinkronkan lokal
//         final freshUser = body!['user'] as Map<String, dynamic>?;
//         if (freshUser != null) {
//           await prefs.setString(AppConfig.keyUser, jsonEncode(freshUser));
//         }
//         return null; // sukses
//       }

//       // Validasi 422
//       if (res.statusCode == 422) {
//         final errors = body?['errors'] as Map<String, dynamic>?;
//         if (errors != null && errors.isNotEmpty) {
//           final first = errors.values.first;
//           return (first is List && first.isNotEmpty)
//               ? first.first.toString()
//               : 'Validasi gagal.';
//         }
//       }

//       return body?['message']?.toString() ?? 'Gagal memperbarui profil.';

//     } on Exception catch (e) {
//       // Data lokal sudah tersimpan, jadi tidak throw — cukup log
//       debugPrint('[AuthService] updateUserData error: $e');
//       return null; // anggap sukses karena lokal sudah tersimpan
//     }
//   }

//   // ── GANTI PASSWORD ────────────────────────────────────────────
//   /// Return null = sukses, String = pesan error
//   static Future<String?> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final res = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/profile/change-password'),
//         headers: await authHeaders(),
//         body: jsonEncode({
//           'current_password':      oldPassword,
//           'password':              newPassword,
//           'password_confirmation': newPassword,
//         }),
//       ).timeout(AppConfig.requestTimeout);

//       final data = _decode(res.body);

//       if (res.statusCode == 200 && data?['success'] == true) {
//         return null; // sukses
//       }

//       // Validasi 422
//       if (res.statusCode == 422) {
//         final errors = data?['errors'] as Map<String, dynamic>?;
//         if (errors != null && errors.isNotEmpty) {
//           final first = errors.values.first;
//           return (first is List && first.isNotEmpty)
//               ? first.first.toString()
//               : 'Validasi gagal.';
//         }
//       }

//       return data?['message']?.toString() ?? 'Gagal mengganti password.';

//     } on Exception catch (e) {
//       return _handleException(e);
//     }
//   }

//   // ── HELPERS PUBLIK ────────────────────────────────────────────
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(AppConfig.keyLoggedIn) ?? false;
//   }

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final t = prefs.getString(AppConfig.keyToken);
//     return (t != null && t.isNotEmpty) ? t : null;
//   }

//   static Future<Map<String, dynamic>> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(AppConfig.keyUser);
//     if (raw == null || raw.isEmpty) return {};
//     try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); }
//     catch (_) { return {}; }
//   }

//   /// Dipakai oleh service lain untuk request yang butuh token
//   static Future<Map<String, String>> authHeaders() async {
//     final token = await getToken();
//     return {
//       'Content-Type':  'application/json',
//       'Accept':        'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ── PRIVATE ───────────────────────────────────────────────────
//   static Map<String, String> _baseHeaders() => {
//     'Content-Type': 'application/json',
//     'Accept':       'application/json',
//   };

//   static Future<void> _saveSession(
//       String token, Map<String, dynamic> user) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(AppConfig.keyToken,  token);
//     await prefs.setString(AppConfig.keyUser,   jsonEncode(user));
//     await prefs.setBool(AppConfig.keyLoggedIn, true);
//   }

//   static Future<void> _clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(AppConfig.keyToken);
//     await prefs.remove(AppConfig.keyUser);
//     await prefs.setBool(AppConfig.keyLoggedIn, false);
//   }

//   static Map<String, dynamic>? _decode(String body) {
//     try { return jsonDecode(body) as Map<String, dynamic>; }
//     catch (_) { return null; }
//   }

//   static String _handleException(Exception e) {
//     final s = e.toString().toLowerCase();
//     if (s.contains('socketexception') || s.contains('connection refused')) {
//       return 'Tidak dapat terhubung ke server.\n'
//           'Pastikan Laragon aktif dan URL di AppConfig benar.';
//     }
//     if (s.contains('timeout')) return 'Koneksi timeout. Cek jaringan lo.';
//     return 'Error: ${e.toString()}';
//   }
// }


// KODE KE 3 AWAL BUKAN VERSI FINAL, ADA UPDATE DI BAWAHNYA

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import '../core/app_config.dart';

// /// AuthService — connect ke Laravel Sanctum
// /// Disesuaikan dengan struktur response AuthController lo:
// /// { success: bool, token: string, user: { ...user, patient: {...} } }

// class AuthService {

//   // ── LOGIN ─────────────────────────────────────────────────────
//   /// Return null = sukses, String = pesan error
//   static Future<String?> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final res = await http.post(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
//         headers: _baseHeaders(),
//         body: jsonEncode({'email': email, 'password': password}),
//       ).timeout(AppConfig.requestTimeout);

//       final data = _decode(res.body);
//       if (data == null) return 'Respons server tidak valid.';

//       // Laravel return { success: true, token: "...", user: {...} }
//       if (res.statusCode == 200 && data['success'] == true) {
//         final token = data['token']?.toString() ?? '';
//         final user  = data['user']  as Map<String, dynamic>? ?? {};

//         await _saveSession(token, user);
//         return null; // null = sukses
//       }

//       return data['message']?.toString() ?? 'Email atau password salah.';

//     } on Exception catch (e) {
//       return _handleException(e);
//     }
//   }

//   // ── REGISTER ──────────────────────────────────────────────────
//   /// Return null = sukses, String = pesan error
//   static Future<String?> register({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String gender,    // 'male' | 'female' | 'other'
//     String? dateOfBirth,       // format: 'yyyy-MM-dd', opsional
//   }) async {
//     try {
//       final res = await http.post(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.registerEndpoint}'),
//         headers: _baseHeaders(),
//         body: jsonEncode({
//           'name':                  name,
//           'email':                 email,
//           'phone':                 phone,
//           'password':              password,
//           'password_confirmation': password,
//           'role':                  'patient',
//           'gender':                gender,
//           if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
//         }),
//       ).timeout(AppConfig.requestTimeout);

//       final data = _decode(res.body);
//       if (data == null) return 'Respons server tidak valid.';

//       // Sukses: status 201 + success: true
//       if ((res.statusCode == 200 || res.statusCode == 201) &&
//           data['success'] == true) {
//         return null;
//       }

//       // Validasi Laravel (422) — ambil error pertama
//       if (res.statusCode == 422) {
//         final errors = data['errors'] as Map<String, dynamic>?;
//         if (errors != null && errors.isNotEmpty) {
//           final first = errors.values.first;
//           return (first is List && first.isNotEmpty)
//               ? first.first.toString()
//               : 'Validasi gagal.';
//         }
//       }

//       return data['message']?.toString() ?? 'Registrasi gagal.';

//     } on Exception catch (e) {
//       return _handleException(e);
//     }
//   }

//   // ── LOGOUT ────────────────────────────────────────────────────
//   static Future<void> logout() async {
//     try {
//       final token = await getToken();
//       if (token != null) {
//         await http.post(
//           Uri.parse('${AppConfig.baseUrl}${AppConfig.logoutEndpoint}'),
//           headers: await authHeaders(),
//         ).timeout(AppConfig.requestTimeout);
//       }
//     } catch (_) {
//       // Gagal di server tetap clear lokal
//     } finally {
//       await _clearSession();
//     }
//   }

//   // ── FETCH PROFIL DARI SERVER ──────────────────────────────────
//   static Future<Map<String, dynamic>?> fetchUserProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse('${AppConfig.baseUrl}${AppConfig.meEndpoint}'),
//         headers: await authHeaders(),
//       ).timeout(AppConfig.requestTimeout);

//       if (res.statusCode == 200) {
//         final data = _decode(res.body);
//         if (data == null) return null;

//         // /api/auth/me return { user: {...} }
//         final user = data['user'] as Map<String, dynamic>? ?? data;
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(AppConfig.keyUser, jsonEncode(user));
//         return user;
//       }
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }

//   // ── HELPERS PUBLIK ────────────────────────────────────────────
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(AppConfig.keyLoggedIn) ?? false;
//   }

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final t = prefs.getString(AppConfig.keyToken);
//     return (t != null && t.isNotEmpty) ? t : null;
//   }

//   static Future<Map<String, dynamic>> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(AppConfig.keyUser);
//     if (raw == null || raw.isEmpty) return {};
//     try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); }
//     catch (_) { return {}; }
//   }

//   /// Dipakai oleh service lain untuk request yang butuh token
//   static Future<Map<String, String>> authHeaders() async {
//     final token = await getToken();
//     return {
//       'Content-Type':  'application/json',
//       'Accept':        'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ── PRIVATE ───────────────────────────────────────────────────
//   static Map<String, String> _baseHeaders() => {
//     'Content-Type': 'application/json',
//     'Accept':       'application/json',
//   };

//   static Future<void> _saveSession(
//       String token, Map<String, dynamic> user) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(AppConfig.keyToken,   token);
//     await prefs.setString(AppConfig.keyUser,    jsonEncode(user));
//     await prefs.setBool(AppConfig.keyLoggedIn,  true);
//   }

//   static Future<void> _clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(AppConfig.keyToken);
//     await prefs.remove(AppConfig.keyUser);
//     await prefs.setBool(AppConfig.keyLoggedIn, false);
//   }

//   static Map<String, dynamic>? _decode(String body) {
//     try { return jsonDecode(body) as Map<String, dynamic>; }
//     catch (_) { return null; }
//   }

//   static String _handleException(Exception e) {
//     final s = e.toString().toLowerCase();
//     if (s.contains('socketexception') || s.contains('connection refused')) {
//       return 'Tidak dapat terhubung ke server.\n'
//           'Pastikan Laragon aktif dan URL di AppConfig benar.';
//     }
//     if (s.contains('timeout')) return 'Koneksi timeout. Cek jaringan lo.';
//     return 'Error: ${e.toString()}';
//   }
// }
