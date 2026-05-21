/// ============================================================
/// APP CONFIG — Smart Urban Health AI
/// Sesuaikan BASE_URL dengan environment lo
/// ============================================================
class AppConfig {
  // ── GANTI SESUAI ENVIRONMENT ──────────────────────────────────
  //
  // Flutter Web di Chrome + Laragon UNTUK LAPTOP:
  //static const String baseUrl = 'http://localhost/smart-urban-health-api/public';
  //
  // Emulator Android + Laragon (HP POCO):
  static const String baseUrl = 'http://10.0.170.38/smart-urban-health-api/public';
  //
  // Python FastAPI ML server (jalankan: uvicorn main:app --relo
  // ad)
  static const String mlBaseUrl = 'http://127.0.0.1:8000';
  // ─────────────────────────────────────────────────────────────

  // ── Auth endpoints ────────────────────────────────────────────
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint    = '/api/auth/login';
  static const String logoutEndpoint   = '/api/auth/logout';
  static const String meEndpoint       = '/api/auth/me';

  // ── Patient endpoints ─────────────────────────────────────────
  static const String profileEndpoint       = '/api/patient/profile';
  static const String dashboardEndpoint     = '/api/patient/dashboard';

  // ── Diagnosis endpoints ───────────────────────────────────────
  static const String diagnosisAssessEndpoint  = '/api/diagnosis/assess';
  static const String diagnosisHistoryEndpoint = '/api/diagnosis/history';
  static const String symptomsEndpoint         = '/api/symptoms';

  // ── Lifestyle endpoints ───────────────────────────────────────
  static const String lifestyleScanEndpoint    = '/api/lifestyle/scan';
  static const String lifestyleHistoryEndpoint = '/api/lifestyle/history';

  // ── ML FastAPI endpoint ───────────────────────────────────────
  static const String mlPredictEndpoint = '/predict';

  // ── Gemini AI Chatbot (ELSA) ─────────────────────────────────
  // Dapatkan API key gratis di: https://aistudio.google.com/apikey
  static const String geminiApiKey = 'AIzaSyBbEroS_DQQG6tRPHt1Ly2lcLRnblxJqn4';

  // ── Timeout ───────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration chatbotTimeout = Duration(seconds: 30);

  // ── SharedPreferences keys ────────────────────────────────────
  static const String keyToken     = 'auth_token';
  static const String keyUser      = 'user_data';
  static const String keyLoggedIn  = 'is_logged_in';
  static const String keyFirstOpen = 'first_open';
}