import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  bool    _obscurePass    = true;
  bool    _obscureConfirm = true;
  bool    _isLoading      = false;
  bool    _agreeTerms     = false;
  String  _selectedGender = ''; // 'male' | 'female' | 'other'
  String? _errorMessage;
  int     _step           = 0;  // 0 = data diri, 1 = akun, 2 = sukses

  late AnimationController _stepCtrl;
  late Animation<double>   _stepOpacity;
  late Animation<Offset>   _stepSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _stepOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _stepSlide = Tween<Offset>(
        begin: const Offset(0.1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose(); _stepCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _errorMessage = 'Nama lengkap wajib diisi.');
        return;
      }
      if (_selectedGender.isEmpty) {
        setState(() => _errorMessage = 'Pilih jenis kelamin terlebih dahulu.');
        return;
      }
    }
    setState(() { _errorMessage = null; _step++; });
    _stepCtrl.reset(); _stepCtrl.forward();
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() { _errorMessage = null; _step--; });
      _stepCtrl.reset(); _stepCtrl.forward();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeTerms) {
      setState(() => _errorMessage = 'Setujui syarat & ketentuan terlebih dahulu.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await AuthService.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      gender:   _selectedGender,   // 'male' / 'female' / 'other'
    );

    if (!mounted) return;

    if (error == null) {
      setState(() { _step = 2; _isLoading = false; });
      _stepCtrl.reset(); _stepCtrl.forward();
    } else {
      setState(() { _errorMessage = error; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1628), Color(0xFF061020)],
            ),
          )),
          Positioned(top: -80, right: -80, child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppTheme.accentOrange.withOpacity(0.06)))),
          Positioned(bottom: -60, left: -60, child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppTheme.primaryTeal.withOpacity(0.06)))),

          SafeArea(child: Column(children: [
            _buildHeader(),
            _buildStepBar(),
            Expanded(child: AnimatedBuilder(
              animation: _stepCtrl,
              builder: (_, __) => SlideTransition(
                position: _stepSlide,
                child: FadeTransition(
                  opacity: _stepOpacity,
                  child: _buildContent(),
                ),
              ),
            )),
          ])),
        ],
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(children: [
      GestureDetector(
        onTap: _prevStep,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20)),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Buat Akun Baru',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
            fontWeight: FontWeight.w800, color: Colors.white)),
        Text(
          _step == 0 ? 'Data Pribadi'
              : _step == 1 ? 'Keamanan Akun' : 'Selesai!',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
            color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
      ]),
    ]),
  );

  Widget _buildStepBar() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
    child: Row(children: List.generate(3, (i) {
      final done   = i < _step;
      final active = i == _step;
      return Expanded(child: Row(children: [
        Expanded(child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 5,
          decoration: BoxDecoration(
            color: done || active
                ? AppTheme.primaryTeal
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
        )),
        if (i < 2) const SizedBox(width: 6),
      ]));
    })),
  );

  Widget _buildContent() {
    if (_step == 2) return _buildSuccess();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(children: [
          if (_errorMessage != null) ...[
            _ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          if (_step == 0) _buildStep0() else _buildStep1(),
        ]),
      ),
    );
  }

  // ── Step 0: Data Pribadi ───────────────────────────────────────
  Widget _buildStep0() => Column(children: [
    AuthTextField(controller: _nameCtrl, label: 'Nama Lengkap',
      hint: 'Masukkan nama lengkap', icon: Icons.person_outline_rounded,
      validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null),
    const SizedBox(height: 16),
    AuthTextField(controller: _phoneCtrl, label: 'Nomor HP',
      hint: '08xxxxxxxxxx', icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone),
    const SizedBox(height: 16),

    // Gender — nilai: 'male', 'female', 'other' (sesuai Laravel)
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Jenis Kelamin',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
          fontWeight: FontWeight.w600, color: Colors.white60, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Row(children: [
        _GenderBtn(label: 'Laki-laki', icon: Icons.male_rounded,
          value: 'male', selected: _selectedGender,
          onTap: () => setState(() => _selectedGender = 'male')),
        const SizedBox(width: 10),
        _GenderBtn(label: 'Perempuan', icon: Icons.female_rounded,
          value: 'female', selected: _selectedGender,
          onTap: () => setState(() => _selectedGender = 'female')),
        const SizedBox(width: 10),
        _GenderBtn(label: 'Lainnya', icon: Icons.person_outlined,
          value: 'other', selected: _selectedGender,
          onTap: () => setState(() => _selectedGender = 'other')),
      ]),
    ]),

    const SizedBox(height: 32),
    AuthGradientButton(label: 'Lanjut', isLoading: false, onTap: _nextStep),
  ]);

  // ── Step 1: Akun ───────────────────────────────────────────────
  Widget _buildStep1() => Column(children: [
    AuthTextField(controller: _emailCtrl, label: 'Email',
      hint: 'nama@email.com', icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Email wajib diisi';
        if (!v.contains('@')) return 'Format email tidak valid';
        return null;
      }),
    const SizedBox(height: 16),
    AuthTextField(controller: _passCtrl, label: 'Password',
      hint: 'Minimal 8 karakter', icon: Icons.lock_outline_rounded,
      obscureText: _obscurePass,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscurePass = !_obscurePass),
        child: Icon(_obscurePass ? Icons.visibility_off_outlined
            : Icons.visibility_outlined, color: Colors.white38, size: 20)),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password wajib diisi';
        if (v.length < 8) return 'Password minimal 8 karakter';
        return null;
      }),
    const SizedBox(height: 16),
    AuthTextField(controller: _confirmCtrl, label: 'Konfirmasi Password',
      hint: 'Ulangi password', icon: Icons.lock_outline_rounded,
      obscureText: _obscureConfirm,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
        child: Icon(_obscureConfirm ? Icons.visibility_off_outlined
            : Icons.visibility_outlined, color: Colors.white38, size: 20)),
      validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null),
    const SizedBox(height: 20),

    // Terms checkbox
    GestureDetector(
      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: _agreeTerms ? AppTheme.primaryTeal : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _agreeTerms
                ? AppTheme.primaryTeal : Colors.white.withOpacity(0.2))),
          child: _agreeTerms
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: RichText(text: TextSpan(
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
            color: Colors.white54, height: 1.5),
          children: [
            const TextSpan(text: 'Saya menyetujui '),
            TextSpan(text: 'Syarat & Ketentuan',
              style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
            const TextSpan(text: ' serta '),
            TextSpan(text: 'Kebijakan Privasi',
              style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
            const TextSpan(text: ' Smart Urban Health AI.'),
          ],
        ))),
      ]),
    ),

    const SizedBox(height: 28),
    AuthGradientButton(label: 'Buat Akun', isLoading: _isLoading, onTap: _register),
    const SizedBox(height: 20),

    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Sudah punya akun? ',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: Colors.white.withOpacity(0.45))),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child))),
        child: Text('Masuk',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: AppTheme.primaryTeal, fontWeight: FontWeight.w700))),
    ]),
  ]);

  // ── Step 2: Sukses ─────────────────────────────────────────────
  Widget _buildSuccess() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: AppTheme.primaryGradient,
            boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.4),
              blurRadius: 30, spreadRadius: 6)]),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
        ),
        const SizedBox(height: 32),
        const Text('Akun Berhasil\nDibuat! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 26,
            fontWeight: FontWeight.w800, color: Colors.white, height: 1.25)),
        const SizedBox(height: 14),
        Text('Selamat datang di Smart Urban Health AI!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: Colors.white.withOpacity(0.5), height: 1.6)),
        const SizedBox(height: 40),
        AuthGradientButton(
          label: 'Mulai Sekarang 🚀', isLoading: false,
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginScreen(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child)),
            (route) => false)),
      ]),
    ),
  );
}

// ── Helper widgets ───────────────────────────────────────────────────

class _GenderBtn extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final VoidCallback onTap;
  const _GenderBtn({required this.label, required this.icon,
    required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.15)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
            color: isSelected ? AppTheme.primaryTeal : Colors.white38),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryTeal : Colors.white38)),
        ]),
      ),
    ));
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(
        fontFamily: 'Poppins', color: AppTheme.danger,
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.5))),
    ]),
  );
}



//END

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../theme/app_theme.dart';
// import '../../services/auth_service.dart';
// import 'login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _confirmPassCtrl = TextEditingController();

//   bool _obscurePass = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;
//   bool _agreeTerms = false;
//   String? _errorMessage;
//   String _selectedGender = '';
//   int _currentStep = 0; // 0 = data diri, 1 = akun, 2 = selesai

//   late AnimationController _stepCtrl;
//   late Animation<double> _stepOpacity;
//   late Animation<Offset> _stepSlide;

//   @override
//   void initState() {
//     super.initState();
//     _stepCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 400));
//     _stepOpacity = Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
//     _stepSlide = Tween<Offset>(
//       begin: const Offset(0.1, 0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
//     _stepCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _phoneCtrl.dispose();
//     _passCtrl.dispose();
//     _confirmPassCtrl.dispose();
//     _stepCtrl.dispose();
//     super.dispose();
//   }

//   void _nextStep() {
//     if (_currentStep == 0) {
//       if (_nameCtrl.text.trim().isEmpty) {
//         setState(() => _errorMessage = 'Nama lengkap wajib diisi');
//         return;
//       }
//       if (_selectedGender.isEmpty) {
//         setState(() => _errorMessage = 'Pilih jenis kelamin terlebih dahulu');
//         return;
//       }
//     }
//     setState(() {
//       _errorMessage = null;
//       _currentStep++;
//     });
//     _stepCtrl.reset();
//     _stepCtrl.forward();
//   }

//   void _prevStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _errorMessage = null;
//         _currentStep--;
//       });
//       _stepCtrl.reset();
//       _stepCtrl.forward();
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _register() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     if (!_agreeTerms) {
//       setState(() => _errorMessage = 'Kamu harus menyetujui syarat & ketentuan');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final success = await AuthService.register(
//         name: _nameCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         phone: _phoneCtrl.text.trim(),
//         password: _passCtrl.text,
//         gender: _selectedGender,
//       );

//       if (!mounted) return;

//       if (success) {
//         setState(() {
//           _currentStep = 2;
//           _isLoading = false;
//         });
//         _stepCtrl.reset();
//         _stepCtrl.forward();
//       } else {
//         setState(() {
//           _errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'Gagal mendaftar. Periksa koneksi internet.';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // BG
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFF0A1628), Color(0xFF061020)],
//               ),
//             ),
//           ),
//           // Decor
//           Positioned(
//             top: -80,
//             right: -80,
//             child: Container(
//               width: 260,
//               height: 260,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.accentOrange.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -60,
//             left: -60,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.primaryTeal.withOpacity(0.06),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Column(
//               children: [
//                 // Header
//                 _buildHeader(),

//                 // Step indicator
//                 _buildStepIndicator(),

//                 // Content
//                 Expanded(
//                   child: AnimatedBuilder(
//                     animation: _stepCtrl,
//                     builder: (_, __) => SlideTransition(
//                       position: _stepSlide,
//                       child: FadeTransition(
//                         opacity: _stepOpacity,
//                         child: _buildStepContent(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _prevStep,
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: Colors.white.withOpacity(0.1)),
//               ),
//               child: const Icon(Icons.arrow_back_rounded,
//                   color: Colors.white70, size: 20),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Buat Akun Baru',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               Text(
//                 _currentStep == 0
//                     ? 'Data Pribadi'
//                     : _currentStep == 1
//                         ? 'Keamanan Akun'
//                         : 'Selesai!',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.primaryTeal,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepIndicator() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
//       child: Row(
//         children: List.generate(3, (i) {
//           final isDone = i < _currentStep;
//           final isActive = i == _currentStep;
//           return Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 400),
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: isDone || isActive
//                           ? AppTheme.primaryTeal
//                           : Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//                 if (i < 2) const SizedBox(width: 6),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildStepContent() {
//     if (_currentStep == 2) return _buildSuccessStep();

//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Error
//             if (_errorMessage != null) ...[
//               _ErrorBanner(message: _errorMessage!),
//               const SizedBox(height: 16),
//             ],

//             if (_currentStep == 0) ...[
//               _buildStep0(),
//             ] else ...[
//               _buildStep1(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStep0() {
//     return Column(
//       children: [
//         _DarkTextField(
//           controller: _nameCtrl,
//           label: 'Nama Lengkap',
//           hint: 'Masukkan nama lengkap',
//           icon: Icons.person_outline_rounded,
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
//             return null;
//           },
//         ),
//         const SizedBox(height: 16),
//         _DarkTextField(
//           controller: _phoneCtrl,
//           label: 'Nomor HP',
//           hint: '08xxxxxxxxxx',
//           icon: Icons.phone_outlined,
//           keyboardType: TextInputType.phone,
//         ),
//         const SizedBox(height: 16),
//         // Gender selector
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Jenis Kelamin',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white60,
//                 letterSpacing: 0.3,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 _GenderButton(
//                   label: 'Laki-laki',
//                   icon: Icons.male_rounded,
//                   isSelected: _selectedGender == 'L',
//                   onTap: () => setState(() => _selectedGender = 'L'),
//                 ),
//                 const SizedBox(width: 12),
//                 _GenderButton(
//                   label: 'Perempuan',
//                   icon: Icons.female_rounded,
//                   isSelected: _selectedGender == 'P',
//                   onTap: () => setState(() => _selectedGender = 'P'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 32),
//         _GradientButton(label: 'Lanjut', isLoading: false, onTap: _nextStep),
//       ],
//     );
//   }

//   Widget _buildStep1() {
//     return Column(
//       children: [
//         _DarkTextField(
//           controller: _emailCtrl,
//           label: 'Email',
//           hint: 'nama@email.com',
//           icon: Icons.email_outlined,
//           keyboardType: TextInputType.emailAddress,
//           validator: (v) {
//             if (v == null || v.isEmpty) return 'Email wajib diisi';
//             if (!v.contains('@')) return 'Format email tidak valid';
//             return null;
//           },
//         ),
//         const SizedBox(height: 16),
//         _DarkTextField(
//           controller: _passCtrl,
//           label: 'Password',
//           hint: 'Minimal 6 karakter',
//           icon: Icons.lock_outline_rounded,
//           obscureText: _obscurePass,
//           suffixIcon: GestureDetector(
//             onTap: () => setState(() => _obscurePass = !_obscurePass),
//             child: Icon(
//               _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//               color: Colors.white38,
//               size: 20,
//             ),
//           ),
//           validator: (v) {
//             if (v == null || v.isEmpty) return 'Password wajib diisi';
//             if (v.length < 6) return 'Password minimal 6 karakter';
//             return null;
//           },
//         ),
//         const SizedBox(height: 16),
//         _DarkTextField(
//           controller: _confirmPassCtrl,
//           label: 'Konfirmasi Password',
//           hint: 'Ulangi password',
//           icon: Icons.lock_outline_rounded,
//           obscureText: _obscureConfirm,
//           suffixIcon: GestureDetector(
//             onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
//             child: Icon(
//               _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//               color: Colors.white38,
//               size: 20,
//             ),
//           ),
//           validator: (v) {
//             if (v != _passCtrl.text) return 'Password tidak cocok';
//             return null;
//           },
//         ),
//         const SizedBox(height: 20),
//         // Terms checkbox
//         GestureDetector(
//           onTap: () => setState(() => _agreeTerms = !_agreeTerms),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 22,
//                 height: 22,
//                 decoration: BoxDecoration(
//                   color: _agreeTerms
//                       ? AppTheme.primaryTeal
//                       : Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(
//                     color: _agreeTerms
//                         ? AppTheme.primaryTeal
//                         : Colors.white.withOpacity(0.2),
//                   ),
//                 ),
//                 child: _agreeTerms
//                     ? const Icon(Icons.check_rounded,
//                         color: Colors.white, size: 14)
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: RichText(
//                   text: TextSpan(
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 12,
//                         color: Colors.white54,
//                         height: 1.5),
//                     children: [
//                       const TextSpan(text: 'Saya menyetujui '),
//                       TextSpan(
//                         text: 'Syarat & Ketentuan',
//                         style: TextStyle(
//                           color: AppTheme.primaryTeal,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const TextSpan(text: ' serta '),
//                       TextSpan(
//                         text: 'Kebijakan Privasi',
//                         style: TextStyle(
//                           color: AppTheme.primaryTeal,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const TextSpan(text: ' Smart Urban Health AI.'),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 28),
//         _GradientButton(
//             label: 'Buat Akun', isLoading: _isLoading, onTap: _register),
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Sudah punya akun? ',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.45),
//               ),
//             ),
//             GestureDetector(
//               onTap: () => Navigator.pushReplacement(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (_, __, ___) => const LoginScreen(),
//                   transitionDuration: const Duration(milliseconds: 350),
//                   transitionsBuilder: (_, anim, __, child) =>
//                       FadeTransition(opacity: anim, child: child),
//                 ),
//               ),
//               child: Text(
//                 'Masuk',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.primaryTeal,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSuccessStep() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 110,
//               height: 110,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: AppTheme.primaryGradient,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.primaryTeal.withOpacity(0.4),
//                     blurRadius: 30,
//                     spreadRadius: 6,
//                   ),
//                 ],
//               ),
//               child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Akun Berhasil\nDibuat! 🎉',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 26,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//                 height: 1.25,
//                 letterSpacing: -0.5,
//               ),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               'Selamat datang di Smart Urban Health AI. Mulai pantau kesehatanmu sekarang!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.5),
//                 height: 1.6,
//               ),
//             ),
//             const SizedBox(height: 40),
//             _GradientButton(
//               label: 'Mulai Sekarang 🚀',
//               isLoading: false,
//               onTap: () {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   PageRouteBuilder(
//                     pageBuilder: (_, __, ___) => const LoginScreen(),
//                     transitionDuration: const Duration(milliseconds: 500),
//                     transitionsBuilder: (_, anim, __, child) =>
//                         FadeTransition(opacity: anim, child: child),
//                   ),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _GenderButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;
//   const _GenderButton({
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           height: 52,
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppTheme.primaryTeal.withOpacity(0.15)
//                 : Colors.white.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: isSelected
//                   ? AppTheme.primaryTeal
//                   : Colors.white.withOpacity(0.1),
//               width: isSelected ? 2 : 1,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon,
//                   color:
//                       isSelected ? AppTheme.primaryTeal : Colors.white38,
//                   size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   color: isSelected ? AppTheme.primaryTeal : Colors.white38,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Reused widgets (import dari login_screen.dart di project nyata) ──

// class _DarkTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final bool obscureText;
//   final Widget? suffixIcon;
//   final TextInputType? keyboardType;
//   final String? Function(String?)? validator;

//   const _DarkTextField({
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.icon,
//     this.obscureText = false,
//     this.suffixIcon,
//     this.keyboardType,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.white60,
//             letterSpacing: 0.3,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: obscureText,
//           keyboardType: keyboardType,
//           style: const TextStyle(
//               fontFamily: 'Poppins', color: Colors.white, fontSize: 14),
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Colors.white.withOpacity(0.2),
//                 fontSize: 14),
//             prefixIcon: Icon(icon, color: Colors.white38, size: 20),
//             suffixIcon: suffixIcon,
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.07),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide:
//                   const BorderSide(color: AppTheme.primaryTeal, width: 1.8),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide:
//                   const BorderSide(color: AppTheme.danger, width: 1.5),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide:
//                   const BorderSide(color: AppTheme.danger, width: 1.8),
//             ),
//             errorStyle: const TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.danger, fontSize: 11),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _GradientButton extends StatelessWidget {
//   final String label;
//   final bool isLoading;
//   final VoidCallback onTap;
//   const _GradientButton(
//       {required this.label,
//       required this.isLoading,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         height: 56,
//         decoration: BoxDecoration(
//           gradient: AppTheme.primaryGradient,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.primaryTeal.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Center(
//           child: isLoading
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2.5, color: Colors.white))
//               : Text(
//                   label,
//                   style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _ErrorBanner extends StatelessWidget {
//   final String message;
//   const _ErrorBanner({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: AppTheme.danger.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.error_outline_rounded,
//               color: AppTheme.danger, size: 18),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               message,
//               style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 color: AppTheme.danger,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }