import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samparka/data/models/user_model.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel? user;
  const EditProfilePage({super.key, this.user});

  static const String routeName = '/edit-profile';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  List<String> _selectedInterests = [];
  bool _isLoading = true;
  String? _profileImageUrl;
  bool _isVerified = false;

  final List<String> _availableInterests = [
    'Music', 'Art', 'Sports', 'Tech', 'Social', 'Food', 'Wellness', 'Others',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _locationController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      final user = widget.user ?? authProvider.userModel;

      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name;
          _ageController.text = user.age?.toString() ?? '';
          _locationController.text = user.locationLabel ?? '';
          _bioController.text = user.bio ?? '';
          _selectedInterests = List<String>.from(user.interests);
          _profileImageUrl = user.avatarUrl;
          _isVerified = user.verified;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker coming soon')),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final userData = {
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'locationLabel': _locationController.text.trim(),
      'bio': _bioController.text.trim(),
      'interests': _selectedInterests,
    };

    final success = await userProvider.updateProfile(userData);

    if (!mounted) return;

    if (success) {
      // Update interests if changed
      if (_selectedInterests.isNotEmpty) {
        await userProvider.updateInterests(_selectedInterests);
      }
      await authProvider.refreshUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return TextButton(
                onPressed: userProvider.isLoading ? null : _saveProfile,
                child: userProvider.isLoading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  'Save',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: 'Enter your age',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your age';
                          final age = int.tryParse(value);
                          if (age == null || age < 13 || age > 120) return 'Please enter a valid age';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'City, Country',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your location';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Text('Profile Verification', style: AppTextStyles.heading3),
                    const Spacer(),
                    Switch(
                      value: _isVerified,
                      onChanged: (value) {
                        setState(() => _isVerified = value);
                        if (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification request submitted. It may take 24-48 hours.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

                if (_isVerified)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentGreen),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.accentGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile is verified',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                Text('Interests', style: AppTextStyles.heading3),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) _selectedInterests.add(interest);
                          else _selectedInterests.remove(interest);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                PrimaryButton(label: 'Save Changes', onPressed: _saveProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
