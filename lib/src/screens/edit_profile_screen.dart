import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _selectedAvatar;
  bool _isSaving = false;

  final List<String> _avatarPresets = const [
    'avatar_1', 'avatar_2', 'avatar_3', 'avatar_4', 'avatar_5', 'avatar_6'
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedAvatar = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: AllGoColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AllGoColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Choose Profile Avatar', style: AllGoTypography.heading3),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final av in _avatarPresets)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedAvatar = av);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _selectedAvatar == av ? AllGoColors.primary : Colors.transparent, width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AllGoColors.primaryLight.withValues(alpha: 0.3),
                          child: Icon(_getIconForAvatar(av), size: 28, color: AllGoColors.primaryDark),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForAvatar(String? avatar) {
    return switch (avatar) {
      'avatar_2' => Icons.face_retouching_natural,
      'avatar_3' => Icons.sentiment_very_satisfied,
      'avatar_4' => Icons.star_border_purple500,
      'avatar_5' => Icons.rocket_launch_outlined,
      'avatar_6' => Icons.pets,
      _ => Icons.person,
    };
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      avatarUrl: _selectedAvatar,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AllGoColors.success),
      );
      Navigator.of(context).pop();
    } else {
      final err = ref.read(authNotifierProvider).errorMessage ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AllGoColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: const AllGoAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AllGoColors.primaryLight.withValues(alpha: 0.3),
                      child: Icon(_getIconForAvatar(_selectedAvatar), size: 48, color: AllGoColors.primaryDark),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(color: AllGoColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AllGoTextField(
                label: 'Phone Number (Verified)',
                controller: TextEditingController(text: user?.phone ?? ''),
                enabled: false,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
              ),
              const SizedBox(height: 16),
              AllGoTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Full name cannot be empty' : null,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
              ),
              const SizedBox(height: 16),
              AllGoTextField(
                label: 'Email Address',
                hint: 'Enter your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val != null && val.isNotEmpty && !val.contains('@')) ? 'Please enter a valid email' : null,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              const SizedBox(height: 32),
              AllGoButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
