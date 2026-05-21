// KODE BARU 13-04-2026

// KODE UPDATE - Smart Urban Health AI
// Disesuaikan dengan struktur main.dart yang sudah ada

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/diagnosis/diagnosis_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/edukasi/edukasi_screen.dart';
import 'screens/splash/splash_screen.dart'; // ← TAMBAHAN BARU
import 'widgets/chatbot/chatbot_fab.dart'; // ← ELSA Chatbot FAB

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Urban Health AI',
      theme: AppTheme.lightTheme,
      // ← Mulai dari SplashScreen, bukan MainPage langsung
      // SplashScreen yang akan routing ke Onboarding → Login → MainPage
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MainPage — dipanggil setelah login berhasil
// Struktur nav SAMA PERSIS seperti main.dart
// ─────────────────────────────────────────────────────────────────────────────

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  // ← Urutan nav SAMA dengan milik lo: Home, Riwayat, Profil, Edukasi
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'Riwayat',
    ),
    _NavItem(
      icon: Icons.person_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
    _NavItem(
      icon: Icons.school_rounded,
      activeIcon: Icons.school_rounded,
      label: 'Edukasi',
    ),
  ];

  // ← Urutan pages SAMA dengan milik lo
  // index: 0=Home, 1=Riwayat, 2=Profil, 3=Edukasi, 4=Diagnosis(FAB)
  final List<Widget> _pages = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
    EdukasiScreen(),
    DiagnosisScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Reset status bar ke dark icons saat di MainPage (bg putih)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onFabTap() async {
    HapticFeedback.mediumImpact();
    await _fabAnimController.forward();
    await _fabAnimController.reverse();
    setState(() => _currentIndex = 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _pages[_currentIndex],
            ),
          ),
          // ── ELSA Chatbot FAB ────────────────────────
          const ChatbotFab(),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: GestureDetector(
          onTap: _onFabTap,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4AA).withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // pulse ring saat aktif di diagnosis screen
                if (_currentIndex == 4)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00D4AA).withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                  ),
                Icon(
                  _currentIndex == 4
                      ? Icons.close_rounded
                      : Icons.biotech_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 0,
      color: Colors.white,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBtn(0), // Home
            _buildNavBtn(1), // Riwayat
            const SizedBox(width: 60), // gap untuk FAB
            _buildNavBtn(2), // Profil
            _buildNavBtn(3), // Edukasi
          ],
        ),
      ),
    );
  }

  Widget _buildNavBtn(int navIndex) {
    // mapping navIndex → pageIndex (sama persis dengan struktur lo)
    int pageIndex;
    switch (navIndex) {
      case 0:
        pageIndex = 0; // Home
        break;
      case 1:
        pageIndex = 1; // Riwayat
        break;
      case 2:
        pageIndex = 2; // Profil
        break;
      case 3:
        pageIndex = 3; // Edukasi
        break;
      default:
        pageIndex = 0;
    }

    final isActive = _currentIndex == pageIndex;
    final item = _navItems[navIndex];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = pageIndex);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4, // ← lo pakai 4, dipertahankan
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // ← dari kode lo
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(4), // ← lo pakai 4
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00D4AA).withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                size: 20, // ← lo pakai 20
                color: isActive
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFFB0B8C8),
              ),
            ),
            const SizedBox(height: 1), // ← lo pakai 1
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFFB0B8C8),
                letterSpacing: 0.3,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}



// // KODE BARU 10-04-2026

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'theme/app_theme.dart';
// import 'screens/home/home_screen.dart';
// import 'screens/diagnosis/diagnosis_screen.dart';
// import 'screens/history/history_screen.dart';
// import 'screens/profile/profile_screen.dart';
// import 'screens/edukasi/edukasi_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ),
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Smart Urban Health AI',
//       theme: AppTheme.lightTheme,
//       home: const MainPage(),
//     );
//   }
// }

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   late AnimationController _fabAnimController;
//   late Animation<double> _fabScaleAnim;

//   final List<_NavItem> _navItems = const [
//     _NavItem(
//       icon: Icons.home_rounded,
//       activeIcon: Icons.home_rounded,
//       label: 'Home',
//     ),
//     _NavItem(
//       icon: Icons.history_rounded,
//       activeIcon: Icons.history_rounded,
//       label: 'Riwayat',
//     ),
//     _NavItem(
//       icon: Icons.person_rounded,
//       activeIcon: Icons.person_rounded,
//       label: 'Profil',
//     ),
//     _NavItem(
//       icon: Icons.school_rounded,
//       activeIcon: Icons.school_rounded,
//       label: 'Edukasi',
//     ),
//   ];

//   // index mapping: 0=Home, 1=History, 2=Edukasi, 3=Profile, 4=Diagnosis(FAB)
//   final List<Widget> _pages = const [
//     HomeScreen(),
//     HistoryScreen(),
//     ProfileScreen(),
//     EdukasiScreen(),
//     DiagnosisScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fabAnimController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _fabScaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
//       CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _fabAnimController.dispose();
//     super.dispose();
//   }

//   void _onFabTap() async {
//     await _fabAnimController.forward();
//     await _fabAnimController.reverse();
//     setState(() => _currentIndex = 4);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (child, animation) =>
//             FadeTransition(opacity: animation, child: child),
//         child: KeyedSubtree(
//           key: ValueKey(_currentIndex),
//           child: _pages[_currentIndex],
//         ),
//       ),
//       floatingActionButton: ScaleTransition(
//         scale: _fabScaleAnim,
//         child: GestureDetector(
//           onTap: _onFabTap,
//           child: Container(
//             width: 62,
//             height: 62,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF00D4AA).withOpacity(0.45),
//                   blurRadius: 16,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // pulse ring
//                 if (_currentIndex == 4)
//                   Container(
//                     width: 62,
//                     height: 62,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFF00D4AA).withOpacity(0.4),
//                         width: 3,
//                       ),
//                     ),
//                   ),
//                 Icon(
//                   _currentIndex == 4
//                       ? Icons.close_rounded
//                       : Icons.biotech_rounded,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   Widget _buildBottomNav() {
//     return BottomAppBar(
//       shape: const CircularNotchedRectangle(),
//       notchMargin: 10,
//       elevation: 0,
//       color: Colors.white,
//       child: SizedBox(
//         height: 64,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavBtn(0),
//             _buildNavBtn(1),
//             const SizedBox(width: 60),
//             _buildNavBtn(2),
//             _buildNavBtn(3),
//           ],
//         ),
//       ),
//     );
//   }

//   // WIDGET LAMA

//   // Widget _buildBottomNav() {
//   //   return BottomAppBar(
//   //     shape: const CircularNotchedRectangle(),
//   //     notchMargin: 10,
//   //     elevation: 0,
//   //     color: Colors.white,
//   //     child: Container(
//   //       height: 64,
//   //       decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         boxShadow: [
//   //           BoxShadow(
//   //             color: Colors.black.withOpacity(0.08),
//   //             blurRadius: 24,
//   //             offset: const Offset(0, -4),
//   //           ),
//   //         ],
//   //       ),
//   //       child: Row(
//   //         mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //         children: [
//   //           _buildNavBtn(0),
//   //           _buildNavBtn(1),
//   //           const SizedBox(width: 60),
//   //           _buildNavBtn(2),
//   //           _buildNavBtn(3),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   //   Widget _buildNavBtn(int navIndex) {
//   //     int pageIndex;

//   //     switch (navIndex) {
//   //       case 0:
//   //         pageIndex = 0; // Home
//   //         break;
//   //       case 1:
//   //         pageIndex = 1; // Riwayat
//   //         break;
//   //       case 2:
//   //         pageIndex = 2; // Profil
//   //         break;
//   //       case 3:
//   //         pageIndex = 3; // Edukasi
//   //         break;
//   //       default:
//   //         pageIndex = 0;
//   //     }

//   //     final isActive = _currentIndex == pageIndex;
//   //     final item = _navItems[navIndex];

//   //     return GestureDetector(
//   //       onTap: () => setState(() => _currentIndex = pageIndex),
//   //       behavior: HitTestBehavior.opaque,
//   //       child: AnimatedContainer(
//   //         duration: const Duration(milliseconds: 250),
//   //         curve: Curves.easeOutCubic,
//   //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             AnimatedContainer(
//   //               duration: const Duration(milliseconds: 250),
//   //               padding: const EdgeInsets.all(6),
//   //               decoration: BoxDecoration(
//   //                 color: isActive
//   //                     ? const Color(0xFF00D4AA).withOpacity(0.12)
//   //                     : Colors.transparent,
//   //                 borderRadius: BorderRadius.circular(10),
//   //               ),
//   //               child: Icon(
//   //                 isActive ? item.activeIcon : item.icon,
//   //                 size: 22,
//   //                 color: isActive
//   //                     ? const Color(0xFF00D4AA)
//   //                     : const Color(0xFFB0B8C8),
//   //               ),
//   //             ),
//   //             const SizedBox(height: 2),
//   //             AnimatedDefaultTextStyle(
//   //               duration: const Duration(milliseconds: 250),
//   //               style: TextStyle(
//   //                 fontSize: 10,
//   //                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//   //                 color: isActive
//   //                     ? const Color(0xFF00D4AA)
//   //                     : const Color(0xFFB0B8C8),
//   //                 letterSpacing: 0.3,
//   //               ),
//   //               child: Text(item.label),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   // }

//   Widget _buildNavBtn(int navIndex) {
//     int pageIndex;

//     switch (navIndex) {
//       case 0:
//         pageIndex = 0;
//         break;
//       case 1:
//         pageIndex = 1;
//         break;
//       case 2:
//         pageIndex = 2;
//         break;
//       case 3:
//         pageIndex = 3;
//         break;
//       default:
//         pageIndex = 0;
//     }

//     final isActive = _currentIndex == pageIndex;
//     final item = _navItems[navIndex];

//     return GestureDetector(
//       onTap: () => setState(() => _currentIndex = pageIndex),
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutCubic,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 4,
//         ), // ← dari 8 jadi 4
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center, // ← tambah ini
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               padding: const EdgeInsets.all(4), // ← dari 6 jadi 4
//               decoration: BoxDecoration(
//                 color: isActive
//                     ? const Color(0xFF00D4AA).withOpacity(0.12)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 isActive ? item.activeIcon : item.icon,
//                 size: 20, // ← dari 22 jadi 20
//                 color: isActive
//                     ? const Color(0xFF00D4AA)
//                     : const Color(0xFFB0B8C8),
//               ),
//             ),
//             const SizedBox(height: 1), // ← dari 2 jadi 1
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 250),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                 color: isActive
//                     ? const Color(0xFF00D4AA)
//                     : const Color(0xFFB0B8C8),
//                 letterSpacing: 0.3,
//               ),
//               child: Text(item.label),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//   const _NavItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
// }
