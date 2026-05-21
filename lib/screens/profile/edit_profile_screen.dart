import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  String? _selectedGender;
  bool _isSaving = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.user['name']?.toString()  ?? '');
    _phoneCtrl = TextEditingController(text: widget.user['phone']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: widget.user['email']?.toString() ?? '');
    final g = widget.user['gender']?.toString() ?? '';
    _selectedGender = (g == 'L' || g == 'P') ? g : null;
    if (widget.user['profile_image'] != null && widget.user['profile_image'].toString().isNotEmpty) {
      final imgPath = widget.user['profile_image'].toString();
      if (imgPath.startsWith('/')) { // local path
        _profileImage = File(imgPath);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e',
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Simpan ke local storage / server
      final updated = {
        ...widget.user,
        'name':   _nameCtrl.text.trim(),
        'phone':  _phoneCtrl.text.trim(),
        'email':  _emailCtrl.text.trim(),
        'gender': _selectedGender ?? '',
        if (_profileImage != null) 'profile_image': _profileImage!.path,
      };
      final error = await AuthService.updateUserData(updated);

      if (mounted) {
        if (error != null) {
          // Ada error dari server, tapi data lokal sudah tersimpan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error,
                  style: const TextStyle(fontFamily: 'Poppins')),
              backgroundColor: AppTheme.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui!',
                  style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: AppTheme.primaryTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e',
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryTeal))
                : const Text('Simpan',
                    style: TextStyle(color: AppTheme.primaryTeal,
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.tealGlow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 36,
                                  fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                            ),
                          ),
                  ),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 28),

            // Form fields
            _buildCard([
              _buildField(
                controller: _nameCtrl,
                label: 'Nama Lengkap',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tidak boleh kosong' : null,
                onChanged: (_) => setState(() {}),
              ),
              _fieldDivider(),
              _buildField(
                controller: _phoneCtrl,
                label: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _fieldDivider(),
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              _fieldDivider(),
              // Gender
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.wc_rounded,
                        color: AppTheme.primaryTeal, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Jenis Kelamin',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted,
                              fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Row(children: [
                        _genderChip('L', 'Laki-laki'),
                        const SizedBox(width: 8),
                        _genderChip('P', 'Perempuan'),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ]),

            const SizedBox(height: 16),

            // Ganti password section
            _buildCard([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFF667EEA), size: 18),
                ),
                title: const Text('Ganti Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins', color: AppTheme.textPrimary)),
                subtitle: const Text('Ubah kata sandi akun kamu',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted,
                        fontFamily: 'Poppins')),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppTheme.textMuted),
                onTap: () => _showChangePasswordSheet(context),
              ),
            ]),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryTeal : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryTeal : AppTheme.divider,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textSecondary,
            )),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(children: children),
  );

  Widget _fieldDivider() =>
      Divider(height: 1, color: AppTheme.divider, indent: 48);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary,
                fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 11, color: AppTheme.textMuted,
                  fontFamily: 'Poppins', fontWeight: FontWeight.w500),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    bool obscureOld = true, obscureNew = true, obscureConf = true;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Ganti Password',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins', color: AppTheme.textPrimary)),
              const SizedBox(height: 24),
              _pwField(ctx, oldCtrl, 'Password Lama', obscureOld,
                  () => setModalState(() => obscureOld = !obscureOld)),
              const SizedBox(height: 12),
              _pwField(ctx, newCtrl, 'Password Baru', obscureNew,
                  () => setModalState(() => obscureNew = !obscureNew)),
              const SizedBox(height: 12),
              _pwField(ctx, confCtrl, 'Konfirmasi Password', obscureConf,
                  () => setModalState(() => obscureConf = !obscureConf)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (newCtrl.text != confCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password tidak cocok',
                              style: TextStyle(fontFamily: 'Poppins')),
                          backgroundColor: AppTheme.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    if (newCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password minimal 6 karakter',
                              style: TextStyle(fontFamily: 'Poppins')),
                          backgroundColor: AppTheme.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    setModalState(() => saving = true);
                    try {
                      final pwError = await AuthService.changePassword(
                        oldPassword: oldCtrl.text,
                        newPassword: newCtrl.text,
                      );
                      if (ctx.mounted) {
                        if (pwError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(pwError,
                                  style: const TextStyle(fontFamily: 'Poppins')),
                              backgroundColor: AppTheme.danger,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Password berhasil diubah!',
                                  style: TextStyle(fontFamily: 'Poppins')),
                              backgroundColor: AppTheme.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal: $e',
                                style: const TextStyle(fontFamily: 'Poppins')),
                            backgroundColor: AppTheme.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } finally {
                      if (ctx.mounted) setModalState(() => saving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Password',
                          style: TextStyle(fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white, fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _pwField(BuildContext ctx, TextEditingController ctrl, String label,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, fontFamily: 'Poppins',
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
              color: AppTheme.textMuted, size: 18),
          onPressed: toggle,
        ),
      ),
    );
  }
}