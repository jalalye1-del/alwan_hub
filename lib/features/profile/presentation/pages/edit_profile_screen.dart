import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/profile/data/profile_repository.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;
  late String _avatarTheme;
  bool _saving = false;

  static const _themes = ['النهار ☀️', 'الغروب 🌅', 'الليل 🌌', 'البحر 🌊'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _cityController = TextEditingController(text: widget.profile.city);
    _bioController = TextEditingController(text: widget.profile.bio);
    _avatarTheme = widget.profile.avatarTheme;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Column(
          children: [
            const AlwanPageHeader(title: 'تعديل الملف الشخصي'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: ResponsiveContent(
                  maxWidth: 760,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _AvatarPreview(theme: _avatarTheme),
                        const SizedBox(height: 8),
                        const Text(
                          'اضغط على النمط لتغيير الصورة الفنية للطبيعة 🌅',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: _themes.map((theme) {
                            return ChoiceChip(
                              label: Text(theme),
                              selected: _avatarTheme == theme,
                              onSelected: (_) =>
                                  setState(() => _avatarTheme = theme),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'بيانات الحساب الشخصي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _nameController,
                          label: 'الاسم',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _cityController,
                          label: 'المدينة والدولة',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _bioController,
                          label: 'نبذة مختصرة',
                          icon: Icons.edit_note_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: const Text('حفظ وتأكيد التغييرات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final profile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      bio: _bioController.text.trim(),
      avatarTheme: _avatarTheme,
    );
    await ProfileRepository().save(profile);
    if (!mounted) return;
    Navigator.pop(context, profile);
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'يرجى إدخال $label' : null,
      decoration: InputDecoration(
        labelText: context.translateInterface(label),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.theme});

  final String theme;

  @override
  Widget build(BuildContext context) {
    final colors = switch (theme) {
      'النهار ☀️' => const [Color(0xFF4FC3F7), Color(0xFFFFF176)],
      'الليل 🌌' => const [Color(0xFF0D1642), Color(0xFF7E57C2)],
      'البحر 🌊' => const [Color(0xFF00B4DB), Color(0xFF0083B0)],
      _ => const [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
    };
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 64),
      ),
    );
  }
}
