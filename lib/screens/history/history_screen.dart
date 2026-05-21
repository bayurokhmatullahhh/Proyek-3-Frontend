// KODE UPDATE — History Screen dengan API real
// Connect ke GET /api/diagnosis/history
// Auto-refresh setelah diagnosis selesai

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<DiagnosisHistoryItem> _diagnosisItems = [];
  bool  _isLoading = true;
  String? _error;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _error = null; _currentPage = 1; });
    try {
      final items = await ApiService.getDiagnosisHistory();
      if (mounted) setState(() { _diagnosisItems = items; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Tidak dapat memuat riwayat.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Riwayat Kesehatan',
                              style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3, fontFamily: 'Poppins')),
                            const SizedBox(height: 4),
                            const Text('Pantau perjalanan kesehatanmu',
                              style: TextStyle(fontSize: 13,
                                color: AppTheme.textMuted, fontFamily: 'Poppins')),
                          ],
                        )),
                        // Refresh button
                        GestureDetector(
                          onTap: _loadHistory,
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(12)),
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryTeal))
                                : const Icon(Icons.refresh_rounded,
                                    color: AppTheme.textSecondary, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryTeal,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.primaryTeal,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 13, fontFamily: 'Poppins'),
                  tabs: [
                    Tab(text: 'Diagnosis (${_diagnosisItems.length})'),
                    const Tab(text: 'Konsultasi'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDiagnosisTab(),
            _buildConsultTab(),
          ],
        ),
      ),
    );
  }

  // ── Tab Diagnosis ─────────────────────────────────────────────
  Widget _buildDiagnosisTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(
          color: AppTheme.primaryTeal));
    }

    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _loadHistory);
    }

    if (_diagnosisItems.isEmpty) {
      return _EmptyView(
        icon: Icons.biotech_rounded,
        title: 'Belum ada riwayat diagnosis',
        subtitle: 'Mulai cek kesehatan kamu dengan tombol AI di tengah bawah',
        actionLabel: 'Cek Sekarang',
        onAction: () {}, // parent akan handle via FAB
      );
    }

    int totalPages = (_diagnosisItems.length / _itemsPerPage).ceil();
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _diagnosisItems.length) endIndex = _diagnosisItems.length;

    List<DiagnosisHistoryItem> currentItems = _diagnosisItems.sublist(startIndex, endIndex);

    return RefreshIndicator(
      color: AppTheme.primaryTeal,
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: currentItems.length + (totalPages > 1 ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == currentItems.length) {
             return _buildPaginationControls(totalPages);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DiagnosisCard(
              item: currentItems[i],
              onTap: () => _showDiagnosisDetail(context, currentItems[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _currentPage > 1 ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? () {
                setState(() { _currentPage--; });
              } : null,
              color: AppTheme.primaryTeal,
              disabledColor: AppTheme.divider,
            ),
          ),
          const SizedBox(width: 16),
          Text('Halaman $_currentPage dari $totalPages',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: _currentPage < totalPages ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < totalPages ? () {
                setState(() { _currentPage++; });
              } : null,
              color: AppTheme.primaryTeal,
              disabledColor: AppTheme.divider,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Konsultasi ────────────────────────────────────────────
  Widget _buildConsultTab() {
    return _EmptyView(
      icon: Icons.chat_bubble_outlined,
      title: 'Riwayat konsultasi belum tersedia',
      subtitle: 'Fitur konsultasi dokter akan segera hadir',
    );
  }

  // ── Detail sheet ──────────────────────────────────────────────
  void _showDiagnosisDetail(
      BuildContext context, DiagnosisHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiagnosisDetailSheet(item: item),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// DIAGNOSIS CARD
// ══════════════════════════════════════════════════════════════════

class _DiagnosisCard extends StatelessWidget {
  final DiagnosisHistoryItem item;
  final VoidCallback onTap;
  const _DiagnosisCard({required this.item, required this.onTap});

  Color get _urgencyColor {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent': return AppTheme.danger;
      case 'semi':   return AppTheme.warning;
      default:       return AppTheme.success;
    }
  }

  String get _urgencyLabel {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent': return '🟥 Darurat';
      case 'semi':   return '🟨 Perlu Perhatian';
      default:       return '🟩 Normal';
    }
  }

  String get _confidencePct =>
      '${(item.confidence * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(children: [
          // Icon box
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A7BD5), Color(0xFF00D4AA)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.biotech_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prediksi Diagnosis',
                style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                  fontFamily: 'Poppins')),
              const SizedBox(height: 3),
              Text(item.topDisease,
                style: const TextStyle(fontSize: 14,
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins'),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.calendar_today_rounded,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(_formatDate(item.date),
                  style: const TextStyle(fontSize: 11,
                      color: AppTheme.textMuted, fontFamily: 'Poppins')),
                const SizedBox(width: 10),
                Icon(Icons.analytics_rounded,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(_confidencePct,
                  style: const TextStyle(fontSize: 11,
                      color: AppTheme.textMuted, fontFamily: 'Poppins')),
              ]),
            ],
          )),

          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _urgencyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(_urgencyLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: _urgencyColor, fontFamily: 'Poppins')),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.textMuted),
          ]),
        ]),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// DIAGNOSIS DETAIL BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════

class _DiagnosisDetailSheet extends StatelessWidget {
  final DiagnosisHistoryItem item;
  const _DiagnosisDetailSheet({required this.item});

  Color get _urgencyColor {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent': return AppTheme.danger;
      case 'semi':   return AppTheme.warning;
      default:       return AppTheme.success;
    }
  }

  String get _urgencyLabel {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent': return 'Darurat';
      case 'semi':   return 'Perlu Perhatian';
      default:       return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A7BD5), Color(0xFF00D4AA)]),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.biotech_rounded,
                    color: Colors.white, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hasil Prediksi AI',
                  style: const TextStyle(fontSize: 12,
                    color: AppTheme.textMuted, fontFamily: 'Poppins')),
                Text(item.topDisease,
                  style: const TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                    fontFamily: 'Poppins')),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                    color: AppTheme.textMuted, size: 18)),
              ),
            ]),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.divider),

          // Content
          Expanded(child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [

              // Stat cards
              Row(children: [
                _StatBox(
                  label: 'Akurasi',
                  value: '${(item.confidence * 100).round()}%',
                  icon: Icons.analytics_rounded,
                  color: AppTheme.primaryTeal),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Urgensi',
                  value: _urgencyLabel,
                  icon: Icons.warning_amber_rounded,
                  color: _urgencyColor),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Tanggal',
                  value: _formatDate(item.date),
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.accentBlue),
              ]),

              const SizedBox(height: 20),

              // Urgency detail
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _urgencyColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _urgencyColor.withOpacity(0.3))),
                child: Row(children: [
                  Icon(Icons.emergency_rounded,
                    color: _urgencyColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Tingkat Urgensi: $_urgencyLabel',
                      style: TextStyle(fontWeight: FontWeight.w700,
                        color: _urgencyColor, fontFamily: 'Poppins',
                        fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(_urgencyDescription,
                      style: TextStyle(fontSize: 12,
                        color: _urgencyColor.withOpacity(0.8),
                        fontFamily: 'Poppins', height: 1.4)),
                  ])),
                ]),
              ),

              const SizedBox(height: 20),

              // Top disease detail
              _DetailSection(
                title: 'Penyakit Teridentifikasi',
                icon: Icons.medical_information_rounded,
                color: AppTheme.primaryTeal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.topDisease,
                      style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Poppins'))),
                    Text('${(item.confidence * 100).round()}%',
                      style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTeal,
                        fontFamily: 'Poppins')),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.confidence,
                      backgroundColor: AppTheme.divider,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryTeal),
                      minHeight: 6)),
                ]),
              ),

              const SizedBox(height: 16),

              // Recommendation based on urgency
              _DetailSection(
                title: 'Rekomendasi Tindakan',
                icon: Icons.tips_and_updates_rounded,
                color: AppTheme.accentOrange,
                child: Column(
                  children: _urgencyRecommendations.map((r) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Container(width: 6, height: 6,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(r,
                          style: const TextStyle(fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontFamily: 'Poppins', height: 1.5))),
                      ]),
                    )
                  ).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Tutup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.divider, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text('Konsultasi Dokter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
                )),
              ]),
            ],
          )),
        ]),
      ),
    );
  }

  String get _urgencyDescription {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent':
        return 'Kondisi serius, butuh penanganan segera. Segera ke IGD.';
      case 'semi':
        return 'Disarankan segera konsultasi ke dokter hari ini.';
      default:
        return 'Kondisi stabil. Monitor kondisi dan istirahat cukup.';
    }
  }

  List<String> get _urgencyRecommendations {
    switch (item.urgencyLevel.toLowerCase()) {
      case 'urgent':
        return [
          'Segera ke IGD atau hubungi 119',
          'Jangan tunda penanganan medis',
          'Minta bantuan orang terdekat',
        ];
      case 'semi':
        return [
          'Kunjungi dokter atau klinik hari ini',
          'Istirahat dan kurangi aktivitas berat',
          'Monitor perkembangan gejala',
        ];
      default:
        return [
          'Monitor kondisi kesehatan secara rutin',
          'Istirahat cukup minimal 7-8 jam',
          'Konsultasi jika gejala memburuk',
        ];
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return raw; }
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800,
          fontSize: 13, color: color, fontFamily: 'Poppins'),
          textAlign: TextAlign.center, maxLines: 1,
          overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10,
          color: AppTheme.textMuted, fontFamily: 'Poppins'),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _DetailSection({required this.title, required this.icon,
      required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
          fontFamily: 'Poppins')),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
// EMPTY & ERROR STATES
// ══════════════════════════════════════════════════════════════════

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyView({required this.icon, required this.title,
      required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppTheme.textMuted.withOpacity(0.08),
            shape: BoxShape.circle),
          child: Icon(icon, size: 36,
              color: AppTheme.textMuted.withOpacity(0.4))),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(color: AppTheme.textSecondary,
            fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: AppTheme.textMuted,
            fontSize: 13, fontFamily: 'Poppins', height: 1.5),
            textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.tealGlow),
              child: Text(actionLabel!,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 13,
                    fontFamily: 'Poppins')),
            ),
          ),
        ],
      ]),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(0.08),
            shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded,
              size: 32, color: AppTheme.danger)),
        const SizedBox(height: 16),
        const Text('Gagal Memuat Riwayat',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15,
              fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: AppTheme.textMuted,
            fontSize: 13, fontFamily: 'Poppins', height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.tealGlow),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Coba Lagi', style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w700, fontSize: 13,
                  fontFamily: 'Poppins')),
            ]),
          ),
        ),
      ]),
    ),
  );
}



// // KODE BARU 20-04-2026

// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   static const List<_HistoryItem> _items = [
//     _HistoryItem(
//       title: 'Prediksi Diagnosis',
//       subtitle: 'Hipertensi - Urgensi Sedang',
//       date: '10 Apr 2025',
//       status: 'Selesai',
//       statusColor: AppTheme.success,
//       icon: Icons.biotech_rounded,
//       iconBg: Color(0xFF3A7BD5),
//     ),
//     _HistoryItem(
//       title: 'Konsultasi Dokter',
//       subtitle: 'dr. Budi - Penyakit Dalam',
//       date: '08 Apr 2025',
//       status: 'Selesai',
//       statusColor: AppTheme.success,
//       icon: Icons.chat_bubble_rounded,
//       iconBg: Color(0xFF667EEA),
//     ),
//     _HistoryItem(
//       title: 'Prediksi Diagnosis',
//       subtitle: 'Diabetes - Urgensi Ringan',
//       date: '05 Apr 2025',
//       status: 'Tinjau Ulang',
//       statusColor: AppTheme.warning,
//       icon: Icons.biotech_rounded,
//       iconBg: Color(0xFF3A7BD5),
//     ),
//     _HistoryItem(
//       title: 'Lab & Vaksin',
//       subtitle: 'Cek Darah Lengkap',
//       date: '01 Apr 2025',
//       status: 'Menunggu',
//       statusColor: AppTheme.info,
//       icon: Icons.science_rounded,
//       iconBg: Color(0xFF00D4AA),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.bgLight,
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.white,
//             elevation: 0,
//             automaticallyImplyLeading: false,
//             expandedHeight: 130,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 color: Colors.white,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Riwayat Kesehatan',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                             color: AppTheme.textPrimary,
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Pantau perjalanan kesehatanmu',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: AppTheme.textMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(52),
//               child: Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabController,
//                   labelColor: AppTheme.primaryTeal,
//                   unselectedLabelColor: AppTheme.textMuted,
//                   indicatorColor: AppTheme.primaryTeal,
//                   indicatorWeight: 3,
//                   indicatorSize: TabBarIndicatorSize.label,
//                   labelStyle: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                     fontFamily: 'Poppins',
//                   ),
//                   tabs: const [
//                     Tab(text: 'Semua'),
//                     Tab(text: 'Diagnosis'),
//                     Tab(text: 'Konsultasi'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildList(_items),
//             _buildList(_items.where((i) => i.title.contains('Prediksi')).toList()),
//             _buildList(_items.where((i) => i.title.contains('Konsultasi')).toList()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildList(List<_HistoryItem> items) {
//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.history_rounded, size: 60, color: AppTheme.textMuted.withOpacity(0.4)),
//             const SizedBox(height: 16),
//             const Text(
//               'Belum ada riwayat',
//               style: TextStyle(
//                 color: AppTheme.textMuted,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//       physics: const BouncingScrollPhysics(),
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) => _HistoryCard(item: items[index]),
//     );
//   }
// }

// class _HistoryCard extends StatelessWidget {
//   final _HistoryItem item;
//   const _HistoryCard({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: AppTheme.cardShadow,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: item.iconBg,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(item.icon, color: Colors.white, size: 24),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   item.subtitle,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppTheme.textSecondary,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today_rounded,
//                         size: 11, color: AppTheme.textMuted),
//                     const SizedBox(width: 4),
//                     Text(
//                       item.date,
//                       style: const TextStyle(
//                           fontSize: 11, color: AppTheme.textMuted),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: item.statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   item.status,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: item.statusColor,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Icon(Icons.arrow_forward_ios_rounded,
//                   size: 12, color: AppTheme.textMuted),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HistoryItem {
//   final String title;
//   final String subtitle;
//   final String date;
//   final String status;
//   final Color statusColor;
//   final IconData icon;
//   final Color iconBg;
//   const _HistoryItem({
//     required this.title,
//     required this.subtitle,
//     required this.date,
//     required this.status,
//     required this.statusColor,
//     required this.icon,
//     required this.iconBg,
//   });
// }


// // import 'package:flutter/material.dart';

// // class HistoryScreen extends StatelessWidget {
// //   const HistoryScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Riwayat")),
// //       body: ListView.builder(
// //         itemCount: 5,
// //         itemBuilder: (context, index) => Card(
// //           margin: const EdgeInsets.all(10),
// //           child: ListTile(
// //             leading: const Icon(Icons.history),
// //             title: Text("Diagnosa ${index + 1}"),
// //             subtitle: const Text("Hasil: Normal"),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }