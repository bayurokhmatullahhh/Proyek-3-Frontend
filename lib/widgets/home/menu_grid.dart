import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../screens/diagnosis/diagnosis_screen.dart';
import '../../screens/health_check/health_check_screen.dart';
import '../../screens/mental_health/mental_health_screen.dart';
import '../../screens/mother_child/mother_child_screen.dart';
import '../../screens/blood_health/blood_health_screen.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  static const List<_MenuItem> _items = [
    _MenuItem(
      icon: Icons.biotech_rounded,
      label: 'Diagnosis\nAI',
      gradient: LinearGradient(
          colors: [Color(0xFF00A896), Color(0xFF00A896)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'diagnosis',
    ),
    _MenuItem(
      icon: Icons.local_hospital_rounded,
      label: 'Layanan\nPuskesmas',
      gradient: LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF3A7BD5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'puskesmas',
    ),
    _MenuItem(
      icon: Icons.family_restroom_rounded,
      label: 'Layanan\nIbu & Anak',
      gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF667EEA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'layanan_ibu_anak',
    ),
    _MenuItem(
      icon: Icons.chat_bubble,
      label: 'Konsultasi\nKesehatan',
      gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF6B35)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'bpjs',
    ),
    _MenuItem(
      icon: Icons.calculate_rounded,
      label: 'Cek\nBMI',
      gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFF59E0B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'health_check',
    ),
    _MenuItem(
      icon: Icons.psychology_rounded,
      label: 'Kesehatan\nMental',
      gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'mental',
    ),
    _MenuItem(
      icon: Icons.bloodtype,
      label: 'Kesehatan\nDarah',
      gradient: LinearGradient(
          colors: [Color(0xFFF43F5E), Color(0xFFF43F5E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'darah',
    ),
    _MenuItem(
      icon: Icons.more_horiz_rounded,
      label: 'Lihat\nSemua',
      gradient: LinearGradient(
          colors: [Color(0xFF5A6478), Color(0xFF3D4558)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      type: 'more',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (context, index) =>
            _MenuCard(item: _items[index]),
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTap(BuildContext context) {
    switch (widget.item.type) {
      case 'diagnosis':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiagnosisScreen()),
        );
        break;
      case 'health_check':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthCheckScreen()),
        );
        break;
      case 'bpjs':
        _showComingSoon(context, 'Asuransi & BPJS');
        break;
      case 'layanan_ibu_anak':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MotherChildScreen()),
        );
        break;
      case 'puskesmas':
        _showComingSoon(context, 'Layanan Puskesmas');
        break;
      case 'mental':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MentalHealthScreen()),
        );
        break;
      case 'darah':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BloodHealthScreen()),
        );
        break;
      case 'more':
        _showAllServices(context);
        break;
    }
  }

  void _showComingSoon(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                gradient: widget.item.gradient,
                shape: BoxShape.circle),
            child: Icon(widget.item.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(name.replaceAll('\n', ' '),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins', color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentOrange.withOpacity(0.3))),
            child: const Text('🚀 Segera Hadir',
                style: TextStyle(color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w700, fontSize: 13,
                    fontFamily: 'Poppins')),
          ),
          const SizedBox(height: 12),
          Text('Fitur $name sedang dalam pengembangan dan akan tersedia di update berikutnya.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted,
                  fontFamily: 'Poppins', height: 1.5)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showAllServices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Semua Layanan', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w800, fontFamily: 'Poppins',
              color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.70,
            physics: const NeverScrollableScrollPhysics(),
            children: MenuGrid._items
                .where((i) => i.type != 'more')
                .map((item) => _MenuCard(item: item))
                .toList(),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp:   (_) { _ctrl.reverse(); _onTap(context); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: widget.item.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: (widget.item.gradient.colors.first)
                        .withOpacity(0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(widget.item.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(widget.item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                      height: 1.25, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final String type;
  const _MenuItem({required this.icon, required this.label,
      required this.gradient, required this.type});
}


// // KODE BARU 12-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class MenuGrid extends StatelessWidget {
//   const MenuGrid({super.key});

//   static const List<_MenuItem> _items = [
//     _MenuItem(
//       icon: Icons.chat_bubble_rounded,
//       label: 'Chat\nDokter',
//       gradient: LinearGradient(
//         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.local_hospital_rounded,
//       label: 'Layanan\nPuskesmas',
//       gradient: LinearGradient(
//         colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.science_rounded,
//       label: 'Lab &\nVaksin',
//       gradient: LinearGradient(
//         colors: [Color(0xFF3A7BD5), Color(0xFF00D4AA)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.shield_rounded,
//       label: 'Asuransi\nKesehatan',
//       gradient: LinearGradient(
//         colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.monitor_heart_rounded,
//       label: 'Cek\nKesehatan',
//       gradient: LinearGradient(
//         colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.face_retouching_natural_rounded,
//       label: 'Kulit &\nKecantikan',
//       gradient: LinearGradient(
//         colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.psychology_rounded,
//       label: 'Kesehatan\nMental',
//       gradient: LinearGradient(
//         colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     _MenuItem(
//       icon: Icons.more_horiz_rounded,
//       label: 'Lihat\nSemua',
//       gradient: LinearGradient(
//         colors: [Color(0xFF5A6478), Color(0xFF3D4558)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: _items.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 4,
//           mainAxisSpacing: 18,
//           crossAxisSpacing: 12,
//           childAspectRatio: 0.75, // lebih tinggi supaya tidak overflow
//         ),
//         itemBuilder: (context, index) {
//           return _MenuCard(item: _items[index]);
//         },
//       ),
//     );
//   }
// }

// class _MenuCard extends StatefulWidget {
//   final _MenuItem item;
//   const _MenuCard({required this.item});

//   @override
//   State<_MenuCard> createState() => _MenuCardState();
// }

// class _MenuCardState extends State<_MenuCard>
//     with SingleTickerProviderStateMixin {

//   late AnimationController _controller;
//   late Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 150),
//     );

//     _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {

//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) => _controller.reverse(),
//       onTapCancel: () => _controller.reverse(),
//       onTap: () {},

//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [

//             Container(
//               width: 54,
//               height: 54,
//               decoration: BoxDecoration(
//                 gradient: widget.item.gradient,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.item.gradient.colors.first.withOpacity(0.35),
//                     blurRadius: 10,
//                     offset: const Offset(0,4),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 widget.item.icon,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               widget.item.label,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//                 height: 1.25,
//               ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MenuItem {
//   final IconData icon;
//   final String label;
//   final LinearGradient gradient;

//   const _MenuItem({
//     required this.icon,
//     required this.label,
//     required this.gradient,
//   });
// }


