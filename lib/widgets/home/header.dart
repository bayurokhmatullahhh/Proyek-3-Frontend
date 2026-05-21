import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeHeader extends StatefulWidget {
  final String displayName;
  final String greeting;
  final bool isLoading;

  const HomeHeader({
    super.key,
    required this.displayName,
    required this.greeting,
    this.isLoading = false,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _searchActive = false;
  final _searchCtrl  = TextEditingController();
  String _searchQuery = '';
  int _notifCount = 2; // nanti dari API

  // Daftar layanan untuk search
  static const List<_SearchItem> _searchableItems = [
    _SearchItem('Prediksi Diagnosis AI', Icons.biotech_rounded, 'diagnosis'),
    _SearchItem('Rekam Medis', Icons.folder_shared_rounded, 'medical'),
    _SearchItem('Riwayat Kesehatan', Icons.history_rounded, 'history'),
    _SearchItem('Asuransi & BPJS', Icons.shield_rounded, 'bpjs'),
    _SearchItem('Bantuan & FAQ', Icons.help_outline_rounded, 'faq'),
    _SearchItem('Edit Profil', Icons.person_outline_rounded, 'profile'),
    _SearchItem('Ganti Password', Icons.lock_outline_rounded, 'password'),
    _SearchItem('Kebijakan Privasi', Icons.privacy_tip_outlined, 'privacy'),
    _SearchItem('Demam', Icons.thermostat_rounded, 'symptom'),
    _SearchItem('Batuk', Icons.air_rounded, 'symptom'),
    _SearchItem('Sakit Kepala', Icons.psychology_alt_rounded, 'symptom'),
  ];

  List<_SearchItem> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return _searchableItems
        .where((i) => i.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showNotifSheet() {
    setState(() => _notifCount = 0);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _NotifSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      child: Column(children: [
        // ── Top row ──────────────────────────────────────────────
        Row(children: [
          // Avatar + greeting
          GestureDetector(
            onTap: () {}, // navigasi ke profil dihandle parent
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.tealGlow),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.displayName.isNotEmpty
                            ? widget.displayName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.greeting} 👋',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
              widget.isLoading
                  ? Container(width: 100, height: 14, margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(7)))
                  : Text(widget.displayName,
                      style: const TextStyle(fontSize: 15,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ],
          )),

          // Location chip
          GestureDetector(
            onTap: _showLocationSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.divider, width: 1)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_rounded,
                    color: AppTheme.primaryTeal, size: 14),
                SizedBox(width: 4),
                Text('Kota Saya',
                    style: TextStyle(fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted, size: 14),
              ]),
            ),
          ),

          const SizedBox(width: 8),

          // Notification bell
          GestureDetector(
            onTap: _showNotifSheet,
            child: Stack(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider, width: 1)),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ),
              if (_notifCount > 0)
                Positioned(
                  top: 7, right: 7,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: AppTheme.accentOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1.5)),
                  ),
                ),
            ]),
          ),
        ]),

        const SizedBox(height: 16),

        // ── Search bar ────────────────────────────────────────────
        Column(children: [
          GestureDetector(
            onTap: () => setState(() => _searchActive = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _searchActive
                        ? AppTheme.primaryTeal : AppTheme.divider,
                    width: _searchActive ? 2 : 1.5)),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: _searchActive
                      ? TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Poppins'),
                          decoration: const InputDecoration(
                            hintText: 'Cari gejala, layanan...',
                            hintStyle: TextStyle(color: AppTheme.textMuted,
                                fontSize: 13, fontFamily: 'Poppins'),
                            border: InputBorder.none),
                        )
                      : const Text('Cari gejala, layanan, atau dokter...',
                          style: TextStyle(fontSize: 13,
                              color: AppTheme.textMuted, fontFamily: 'Poppins')),
                ),
                // AI badge atau close
                _searchActive
                    ? GestureDetector(
                        onTap: () => setState(() {
                          _searchActive = false;
                          _searchQuery  = '';
                          _searchCtrl.clear();
                        }),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: AppTheme.divider,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: AppTheme.textSecondary),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(7),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Row(children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 13),
                          SizedBox(width: 3),
                          Text('AI', style: TextStyle(color: Colors.white,
                              fontSize: 11, fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins')),
                        ]),
                      ),
              ]),
            ),
          ),

          // Search results dropdown
          if (_searchActive && _searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.elevatedShadow,
                  border: Border.all(color: AppTheme.divider)),
              child: Column(
                children: _searchResults.asMap().entries.map((e) {
                  final isLast = e.key == _searchResults.length - 1;
                  final item   = e.value;
                  return Column(children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchActive = false;
                          _searchQuery  = '';
                          _searchCtrl.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(item.icon,
                                color: AppTheme.primaryTeal, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.label,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Poppins'))),
                          const Icon(Icons.north_west_rounded,
                              size: 14, color: AppTheme.textMuted),
                        ]),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppTheme.divider,
                          indent: 16),
                  ]);
                }).toList(),
              ),
            ),
        ]),
      ]),
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Pilih Lokasi', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w700, fontFamily: 'Poppins',
              color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          ...[
            'Puskesmas Setempat',
            'Klinik Terdekat',
            'Rumah Sakit Daerah',
          ].map((loc) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider)),
              child: Row(children: [
                const Icon(Icons.local_hospital_rounded,
                    color: AppTheme.primaryTeal, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(loc, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'))),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppTheme.textMuted),
              ]),
            ),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Notification Sheet ────────────────────────────────────────────────

class _NotifSheet extends StatelessWidget {
  const _NotifSheet();

  static const List<_Notif> _notifs = [
    _Notif(
      icon: Icons.biotech_rounded,
      title: 'Hasil Diagnosis Siap',
      body: 'Prediksi diagnosis kamu telah selesai dianalisis',
      time: '2 jam lalu',
      color: Color(0xFF00D4AA),
      isRead: false,
    ),
    _Notif(
      icon: Icons.health_and_safety_rounded,
      title: 'Pengingat Kesehatan',
      body: 'Jangan lupa minum air 8 gelas hari ini 💧',
      time: '5 jam lalu',
      color: Color(0xFF3A7BD5),
      isRead: false,
    ),
    _Notif(
      icon: Icons.stars_rounded,
      title: 'Smart Points Bertambah!',
      body: 'Kamu mendapatkan 10 poin dari diagnosis terakhir',
      time: '1 hari lalu',
      color: Color(0xFFF59E0B),
      isRead: true,
    ),
    _Notif(
      icon: Icons.system_update_rounded,
      title: 'Pembaruan Tersedia',
      body: 'Versi terbaru Smart Health AI sudah tersedia',
      time: '3 hari lalu',
      color: Color(0xFF8B5CF6),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            const Text('Notifikasi', style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                color: AppTheme.textPrimary)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Tandai semua dibaca',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _notifs.length,
          itemBuilder: (_, i) => _NotifTile(notif: _notifs[i]),
        )),
      ]),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : AppTheme.primaryTeal.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: notif.isRead ? AppTheme.divider
                : AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: notif.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(notif.icon, color: notif.color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(children: [
            Expanded(child: Text(notif.title, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: notif.isRead
                    ? AppTheme.textPrimary : AppTheme.primaryTeal))),
            if (!notif.isRead)
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 3),
          Text(notif.body, style: const TextStyle(fontSize: 12,
              color: AppTheme.textSecondary, fontFamily: 'Poppins',
              height: 1.4)),
          const SizedBox(height: 5),
          Text(notif.time, style: const TextStyle(fontSize: 10,
              color: AppTheme.textMuted, fontFamily: 'Poppins')),
        ])),
      ]),
    );
  }
}

class _Notif {
  final IconData icon;
  final String title, body, time;
  final Color color;
  final bool isRead;
  const _Notif({required this.icon, required this.title,
      required this.body, required this.time,
      required this.color, required this.isRead});
}

class _SearchItem {
  final String label;
  final IconData icon;
  final String type;
  const _SearchItem(this.label, this.icon, this.type);
}



// // KODE BARU 12-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final topPad = MediaQuery.of(context).padding.top;
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Responsive location text
//     final locationText =
//         screenWidth < 360 ? "Puskesmas" : "Puskesmas Kota";

//     return Container(
//       padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 28),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(32),
//           bottomRight: Radius.circular(32),
//         ),
//       ),
//       child: Column(
//         children: [

//           /// =========================
//           /// TOP HEADER ROW
//           /// =========================
//           Row(
//             children: [

//               /// Avatar
//               GestureDetector(
//                 onTap: () {},
//                 child: Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     gradient: AppTheme.primaryGradient,
//                     shape: BoxShape.circle,
//                     boxShadow: AppTheme.tealGlow,
//                   ),
//                   child: const Icon(
//                     Icons.person_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               /// Greeting
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Selamat Pagi 👋',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textMuted,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       'Masuk / Daftar',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.primaryTeal,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               /// Location chip
//               Flexible(
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: AppTheme.bgSurface,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: AppTheme.divider, width: 1),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [

//                       const Icon(
//                         Icons.location_on_rounded,
//                         color: AppTheme.primaryTeal,
//                         size: 14,
//                       ),

//                       const SizedBox(width: 4),

//                       Flexible(
//                         child: Text(
//                           locationText,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: AppTheme.textSecondary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 8),

//               /// Notification
//               GestureDetector(
//                 onTap: () {},
//                 child: Stack(
//                   children: [

//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppTheme.bgSurface,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: AppTheme.divider,
//                           width: 1,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.notifications_none_rounded,
//                         color: AppTheme.textSecondary,
//                         size: 20,
//                       ),
//                     ),

//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: AppTheme.accentOrange,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           /// =========================
//           /// SEARCH BAR
//           /// =========================
//           Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: AppTheme.bgSurface,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: AppTheme.divider,
//                 width: 1.5,
//               ),
//             ),
//             child: Row(
//               children: [

//                 const SizedBox(width: 16),

//                 const Icon(
//                   Icons.search_rounded,
//                   color: AppTheme.textMuted,
//                   size: 20,
//                 ),

//                 const SizedBox(width: 10),

//                 const Expanded(
//                   child: Text(
//                     'Cari gejala, dokter, layanan...',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: AppTheme.textMuted,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),

//                 /// AI button
//                 Container(
//                   margin: const EdgeInsets.all(6),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     gradient: AppTheme.primaryGradient,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   alignment: Alignment.center,
//                   child: const Row(
//                     children: [

//                       Icon(
//                         Icons.auto_awesome_rounded,
//                         color: Colors.white,
//                         size: 14,
//                       ),

//                       SizedBox(width: 4),

//                       Text(
//                         'AI',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
