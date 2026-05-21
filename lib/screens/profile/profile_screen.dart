import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
// ─── sub-screens ────────────────────────────────────────────────
import 'edit_profile_screen.dart';
import 'rekam_medis_screen.dart';
import 'asuransi_bpjs_screen.dart';
import 'notifikasi_screen.dart';
import 'bantuan_faq_screen.dart';
import 'kebijakan_privasi_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _user = {};
  bool _isLoadingProfile = true;
  bool _isDarkMode = false;

  // ── Stats (nanti bisa dari API) ──
  int _diagnosisCount = 12;
  int _konsultasiCount = 5;
  int _smartPts = 340;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    final cached = await AuthService.getUserData();
    if (mounted)
      setState(() {
        _user = cached;
        _isLoadingProfile = false;
      });

    final fresh = await AuthService.fetchUserProfile();
    if (fresh != null && mounted) setState(() => _user = fresh);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Kamu akan keluar dari akun ini.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.primaryTeal),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
          (route) => false,
        );
      }
    }
  }

  // Navigasi ke edit profil dan refresh setelah kembali
  Future<void> _goToEditProfile() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      _slide(EditProfileScreen(user: _user)),
    );
    if (updated != null && mounted) setState(() => _user = updated);
  }

  String get _displayName => _user['name']?.toString() ?? 'Pengguna';
  String get _displayEmail => _user['email']?.toString() ?? '-';
  String get _displayPhone => _user['phone']?.toString() ?? '-';
  String get _displayGender {
    final g = _user['patient']?['gender']?.toString() ?? '';
    return g == 'male'
        ? 'Laki-laki'
        : g == 'female'
        ? 'Perempuan'
        : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: _loadProfile,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildAkunSection(),
                  _buildPreferensiSection(),
                  _buildLainnyaSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadProfile,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingProfile
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryTeal,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Avatar — tap untuk edit profil
            GestureDetector(
              onTap: _goToEditProfile,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.tealGlow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (_user['profile_image'] != null && _user['profile_image'].toString().isNotEmpty)
                        ? Image.file(File(_user['profile_image'].toString()), fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              _displayName.isNotEmpty
                                  ? _displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: _goToEditProfile,
              child: Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _displayEmail,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 20),

            // Stats — tiap item bisa di-tap
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.navyGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Row(
                children: [
                  _statItem(
                    '$_diagnosisCount',
                    'Diagnosis',
                    AppTheme.primaryTeal,
                    _onDiagnosisTap,
                  ),
                  _divider(),
                  _statItem(
                    '$_konsultasiCount',
                    'Konsultasi',
                    const Color(0xFF667EEA),
                    _onKonsultasiTap,
                  ),
                  _divider(),
                  _statItem(
                    '$_smartPts',
                    'Smart Pts',
                    AppTheme.accentOrange,
                    _onSmartPtsTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Stats tap handlers
  void _onDiagnosisTap() {
    // Navigasi ke tab Riwayat filter Diagnosis
    // (Sesuaikan index bottom nav di main screen kamu)
    _showStatInfo(
      'Diagnosis',
      '$_diagnosisCount diagnosis telah dilakukan',
      'Lihat semua hasil diagnosis kamu di tab Riwayat.',
      AppTheme.primaryTeal,
      Icons.biotech_rounded,
    );
  }

  void _onKonsultasiTap() {
    _showStatInfo(
      'Konsultasi',
      '$_konsultasiCount konsultasi selesai',
      'Lihat riwayat konsultasi dokter di tab Riwayat.',
      const Color(0xFF667EEA),
      Icons.medical_services_rounded,
    );
  }

  void _onSmartPtsTap() {
    _showStatInfo(
      'Smart Points',
      '$_smartPts poin terkumpul',
      'Gunakan Smart Points untuk diskon konsultasi dan produk perawatan kulit.',
      AppTheme.accentOrange,
      Icons.stars_rounded,
    );
  }

  void _showStatInfo(
    String title,
    String headline,
    String desc,
    Color color,
    IconData icon,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              headline,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Oke',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String val, String label, Color color, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Text(
                val,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1));

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return GestureDetector(
      onTap: _goToEditProfile,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryTeal,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryTeal,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.person_outline_rounded,
              'Nama Lengkap',
              _displayName,
            ),
            _infoDivider(),
            _infoRow(Icons.phone_outlined, 'Nomor HP', _displayPhone),
            _infoDivider(),
            _infoRow(Icons.wc_rounded, 'Jenis Kelamin', _displayGender),
            _infoDivider(),
            _infoRow(Icons.email_outlined, 'Email', _displayEmail),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoDivider() =>
      Divider(height: 1, color: AppTheme.divider, indent: 48);

  // ── Section AKUN ──────────────────────────────────────────────
  Widget _buildAkunSection() => _sectionWrapper('AKUN', [
    _SettingRow(
      icon: Icons.medical_information_rounded,
      label: 'Rekam Medis',
      color: const Color(0xFF00D4AA),
      onTap: () => Navigator.push(context, _slide(const RekamMedisScreen())),
    ),
    _rowDivider(),
    _SettingRow(
      icon: Icons.shield_outlined,
      label: 'Asuransi & BPJS',
      color: const Color(0xFF667EEA),
      onTap: () => Navigator.push(context, _slide(const AsuransiBpjsScreen())),
    ),
  ]);

  // ── Section PREFERENSI ────────────────────────────────────────
  Widget _buildPreferensiSection() => _sectionWrapper('PREFERENSI', [
    _SettingRow(
      icon: Icons.notifications_none_rounded,
      label: 'Notifikasi',
      color: const Color(0xFFF59E0B),
      onTap: () => Navigator.push(context, _slide(const NotifikasiScreen())),
    ),
    _rowDivider(),
    // Bahasa — hanya Indonesia, tampilkan info saja
    _SettingRow(
      icon: Icons.language_rounded,
      label: 'Bahasa',
      color: const Color(0xFF8B5CF6),
      trailing: 'Indonesia',
      onTap: () => _showLanguageInfo(),
    ),
    _rowDivider(),
    // Tema Gelap — toggle dengan feedback
    _ToggleRow(
      icon: Icons.dark_mode_outlined,
      label: 'Tema Gelap',
      color: const Color(0xFF5A6478),
      value: _isDarkMode,
      onChanged: (v) {
        setState(() => _isDarkMode = v);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              v ? 'Tema gelap diaktifkan' : 'Tema terang diaktifkan',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppTheme.primaryTeal,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Jika pakai ThemeProvider, panggil: Provider.of<ThemeProvider>(context, listen: false).toggle();
      },
    ),
  ]);

  void _showLanguageInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Bahasa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _langOption('🇮🇩', 'Bahasa Indonesia', true),
            _langOption('🇬🇧', 'English', false),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String flag, String name, bool selected) =>
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          if (!selected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$name segera tersedia',
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
                backgroundColor: AppTheme.primaryTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryTeal.withOpacity(0.08)
                : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryTeal.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: selected
                        ? AppTheme.primaryTeal
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
            ],
          ),
        ),
      );

  // ── Section LAINNYA ───────────────────────────────────────────
  Widget _buildLainnyaSection() => _sectionWrapper('LAINNYA', [
    _SettingRow(
      icon: Icons.help_outline_rounded,
      label: 'Bantuan & FAQ',
      color: const Color(0xFF22C55E),
      onTap: () => Navigator.push(context, _slide(const BantuanFaqScreen())),
    ),
    _rowDivider(),
    _SettingRow(
      icon: Icons.privacy_tip_outlined,
      label: 'Kebijakan Privasi',
      color: const Color(0xFF3A7BD5),
      onTap: () =>
          Navigator.push(context, _slide(const KebijakanPrivasiScreen())),
    ),
    _rowDivider(),
    _SettingRow(
      icon: Icons.logout_rounded,
      label: 'Keluar',
      color: AppTheme.danger,
      isDestructive: true,
      onTap: _logout,
    ),
  ]);

  // ── Helpers ───────────────────────────────────────────────────
  Widget _sectionWrapper(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.9,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _rowDivider() =>
      Divider(height: 1, indent: 60, color: AppTheme.divider);

  Route<Map<String, dynamic>> _slide(Widget page) =>
      PageRouteBuilder<Map<String, dynamic>>(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

// ── Reusable Widgets ────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.color,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDestructive ? AppTheme.danger : AppTheme.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontFamily: 'Poppins',
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppTheme.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}
