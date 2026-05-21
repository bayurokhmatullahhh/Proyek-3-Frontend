import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool    _obscurePass  = true;
  bool    _isLoading    = false;
  String? _errorMessage;

  late AnimationController _fadeCtrl, _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) { _fadeCtrl.forward(); _slideCtrl.forward(); }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _fadeCtrl.dispose();  _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    // Return null = sukses, String = pesan error dari server
    final error = await AuthService.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainPage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false,
      );
    } else {
      setState(() { _errorMessage = error; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1628), Color(0xFF061020)],
              ),
            ),
          ),
          Positioned(top: -120, left: -60, right: -60,
            child: Container(height: 340,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(0.07)))),
          Positioned(top: 0, right: -80,
            child: Container(width: 220, height: 220,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.accentBlue.withOpacity(0.06)))),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 28),
                    _buildRegisterRow(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() => Column(children: [
    Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle, gradient: AppTheme.primaryGradient,
        boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.4),
            blurRadius: 24, spreadRadius: 4)]),
      child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 36),
    ),
    const SizedBox(height: 16),
    RichText(textAlign: TextAlign.center, text: const TextSpan(
      style: TextStyle(fontFamily: 'Poppins'),
      children: [
        TextSpan(text: 'Smart Urban Health ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        TextSpan(text: 'AI',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryTeal)),
      ],
    )),
    const SizedBox(height: 6),
    Text('Masuk untuk melanjutkan',
      style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: Colors.white.withOpacity(0.45))),
  ]);

  Widget _buildForm() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Selamat Datang 👋',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
              fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Masuk ke akun Smart Health kamu',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: Colors.white.withOpacity(0.45))),
        const SizedBox(height: 28),

        if (_errorMessage != null) ...[
          AuthErrorBanner(message: _errorMessage!),
          const SizedBox(height: 16),
        ],

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
          hint: '••••••••', icon: Icons.lock_outline_rounded,
          obscureText: _obscurePass,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(_obscurePass ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
                color: Colors.white38, size: 20)),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password wajib diisi';
            if (v.length < 6) return 'Password minimal 6 karakter';
            return null;
          }),
        const SizedBox(height: 12),

        Align(alignment: Alignment.centerRight,
          child: GestureDetector(onTap: () {},
            child: Text('Lupa Password?',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 28),

        AuthGradientButton(label: 'Masuk', isLoading: _isLoading, onTap: _login),
      ]),
    ),
  );

  Widget _buildRegisterRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Belum punya akun? ',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: Colors.white.withOpacity(0.45))),
      GestureDetector(
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RegisterScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child),
        )),
        child: Text('Daftar Sekarang',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: AppTheme.primaryTeal, fontWeight: FontWeight.w700)),
      ),
    ],
  );
}

// ── Shared auth widgets (dipakai login & register) ───────────────────

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
          fontWeight: FontWeight.w600, color: Colors.white60, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Poppins',
              color: Colors.white.withOpacity(0.2), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.8)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.danger, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.danger, width: 1.8)),
          errorStyle: const TextStyle(fontFamily: 'Poppins',
              color: AppTheme.danger, fontSize: 11),
        ),
      ),
    ]);
  }
}

class AuthGradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const AuthGradientButton({super.key, required this.label,
      required this.isLoading, required this.onTap});

  @override
  State<AuthGradientButton> createState() => _AuthGradientButtonState();
}

class _AuthGradientButtonState extends State<AuthGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Center(child: widget.isLoading
            ? const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(widget.label, style: const TextStyle(fontFamily: 'Poppins',
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
      ),
    ),
  );
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Poppins',
          color: AppTheme.danger, fontSize: 12,
          fontWeight: FontWeight.w500, height: 1.5))),
    ]),
  );
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../theme/app_theme.dart';
// import '../../services/auth_service.dart';
// import '../../main.dart'; // MainPage
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();

//   bool _obscurePass = true;
//   bool _isLoading = false;
//   String? _errorMessage;

//   late AnimationController _fadeCtrl;
//   late AnimationController _slideCtrl;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();

//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );

//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 700));
//     _slideCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 700));

//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
//     );
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.12),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

//     Future.delayed(const Duration(milliseconds: 100), () {
//       _fadeCtrl.forward();
//       _slideCtrl.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     _fadeCtrl.dispose();
//     _slideCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final success = await AuthService.login(
//         email: _emailCtrl.text.trim(),
//         password: _passCtrl.text,
//       );

//       if (!mounted) return;

//       if (success) {
//         Navigator.of(context).pushAndRemoveUntil(
//           PageRouteBuilder(
//             pageBuilder: (_, __, ___) => const MainPage(),
//             transitionDuration: const Duration(milliseconds: 500),
//             transitionsBuilder: (_, anim, __, child) => FadeTransition(
//               opacity: anim,
//               child: child,
//             ),
//           ),
//           (route) => false,
//         );
//       } else {
//         setState(() {
//           _errorMessage = 'Email atau password salah. Coba lagi.';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet.';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Dark gradient bg
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFF0A1628), Color(0xFF061020)],
//               ),
//             ),
//           ),

//           // Top decorative arc
//           Positioned(
//             top: -120,
//             left: -60,
//             right: -60,
//             child: Container(
//               height: 340,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.primaryTeal.withOpacity(0.07),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 0,
//             right: -80,
//             child: Container(
//               width: 220,
//               height: 220,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.accentBlue.withOpacity(0.06),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 40),

//                       // Logo
//                       _buildLogo(),

//                       const SizedBox(height: 40),

//                       // Form card
//                       _buildFormCard(),

//                       const SizedBox(height: 28),

//                       // Register
//                       _buildRegisterRow(),

//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo() {
//     return Column(
//       children: [
//         Container(
//           width: 72,
//           height: 72,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: AppTheme.primaryGradient,
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.primaryTeal.withOpacity(0.4),
//                 blurRadius: 24,
//                 spreadRadius: 4,
//               ),
//             ],
//           ),
//           child: const Icon(Icons.health_and_safety_rounded,
//               color: Colors.white, size: 36),
//         ),
//         const SizedBox(height: 16),
//         RichText(
//           textAlign: TextAlign.center,
//           text: const TextSpan(
//             style: TextStyle(fontFamily: 'Poppins'),
//             children: [
//               TextSpan(
//                 text: 'Smart Urban Health ',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               TextSpan(
//                 text: 'AI',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: AppTheme.primaryTeal,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Masuk untuk melanjutkan',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 13,
//             color: Colors.white.withOpacity(0.45),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFormCard() {
//     return Container(
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(32),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Selamat Datang 👋',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Masuk ke akun Smart Health kamu',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.45),
//               ),
//             ),

//             const SizedBox(height: 28),

//             // Error banner
//             if (_errorMessage != null) ...[
//               _ErrorBanner(message: _errorMessage!),
//               const SizedBox(height: 16),
//             ],

//             // Email
//             _DarkTextField(
//               controller: _emailCtrl,
//               label: 'Email',
//               hint: 'nama@email.com',
//               icon: Icons.email_outlined,
//               keyboardType: TextInputType.emailAddress,
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'Email wajib diisi';
//                 if (!v.contains('@')) return 'Format email tidak valid';
//                 return null;
//               },
//             ),

//             const SizedBox(height: 16),

//             // Password
//             _DarkTextField(
//               controller: _passCtrl,
//               label: 'Password',
//               hint: '••••••••',
//               icon: Icons.lock_outline_rounded,
//               obscureText: _obscurePass,
//               suffixIcon: GestureDetector(
//                 onTap: () => setState(() => _obscurePass = !_obscurePass),
//                 child: Icon(
//                   _obscurePass
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: Colors.white38,
//                   size: 20,
//                 ),
//               ),
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'Password wajib diisi';
//                 if (v.length < 6) return 'Password minimal 6 karakter';
//                 return null;
//               },
//             ),

//             const SizedBox(height: 12),

//             // Forgot password
//             Align(
//               alignment: Alignment.centerRight,
//               child: GestureDetector(
//                 onTap: () {},
//                 child: Text(
//                   'Lupa Password?',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 12,
//                     color: AppTheme.primaryTeal,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 28),

//             // Login button
//             _GradientButton(
//               label: 'Masuk',
//               isLoading: _isLoading,
//               onTap: _login,
//             ),

//             const SizedBox(height: 20),

//             // Divider
//             Row(
//               children: [
//                 Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                   child: Text(
//                     'atau masuk dengan',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       color: Colors.white.withOpacity(0.35),
//                     ),
//                   ),
//                 ),
//                 Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Social login row
//             Row(
//               children: [
//                 Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded)),
//                 const SizedBox(width: 12),
//                 Expanded(child: _SocialButton(label: 'BPJS', icon: Icons.shield_rounded)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRegisterRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Belum punya akun? ',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 13,
//             color: Colors.white.withOpacity(0.45),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.of(context).push(
//               PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => const RegisterScreen(),
//                 transitionDuration: const Duration(milliseconds: 400),
//                 transitionsBuilder: (_, anim, __, child) => SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(1, 0),
//                     end: Offset.zero,
//                   ).animate(
//                     CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
//                   ),
//                   child: child,
//                 ),
//               ),
//             );
//           },
//           child: Text(
//             'Daftar Sekarang',
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 13,
//               color: AppTheme.primaryTeal,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─── Reusable widgets ───────────────────────────────────────────────

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
//             fontFamily: 'Poppins',
//             color: Colors.white,
//             fontSize: 14,
//           ),
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               fontFamily: 'Poppins',
//               color: Colors.white.withOpacity(0.2),
//               fontSize: 14,
//             ),
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
//               borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: AppTheme.danger, width: 1.8),
//             ),
//             errorStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               color: AppTheme.danger,
//               fontSize: 11,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _GradientButton extends StatefulWidget {
//   final String label;
//   final bool isLoading;
//   final VoidCallback onTap;
//   const _GradientButton({
//     required this.label,
//     required this.isLoading,
//     required this.onTap,
//   });

//   @override
//   State<_GradientButton> createState() => _GradientButtonState();
// }

// class _GradientButtonState extends State<_GradientButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 120));
//     _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
//         CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _scale,
//       child: GestureDetector(
//         onTapDown: (_) => _ctrl.forward(),
//         onTapUp: (_) {
//           _ctrl.reverse();
//           widget.onTap();
//         },
//         onTapCancel: () => _ctrl.reverse(),
//         child: Container(
//           width: double.infinity,
//           height: 56,
//           decoration: BoxDecoration(
//             gradient: widget.isLoading
//                 ? const LinearGradient(
//                     colors: [Color(0xFF00A896), Color(0xFF008F7A)])
//                 : AppTheme.primaryGradient,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.primaryTeal.withOpacity(0.4),
//                 blurRadius: 20,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Center(
//             child: widget.isLoading
//                 ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                       color: Colors.white,
//                     ),
//                   )
//                 : Text(
//                     widget.label,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SocialButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   const _SocialButton({required this.label, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.white70, size: 20),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Colors.white70,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
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