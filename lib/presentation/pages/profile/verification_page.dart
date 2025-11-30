import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/primary_button.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  static const String routeName = '/verification';

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _citizenshipFront;
  File? _citizenshipBack;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        if (isFront) {
          _citizenshipFront = File(pickedFile.path);
        } else {
          _citizenshipBack = File(pickedFile.path);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_citizenshipFront == null || _citizenshipBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both citizenship card photos'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.submitVerification(
      phoneNumber: _phoneController.text.trim(),
      citizenshipFrontPath: _citizenshipFront!.path,
      citizenshipBackPath: _citizenshipBack!.path,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification submitted successfully! Admin will review your request.'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Refresh auth provider to get updated verification status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Failed to submit verification'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Get Verified'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Verify Your Account',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit your citizenship card and phone number for verification',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone_rounded),
                    prefixText: '+977 ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Citizenship Front
                Text(
                  'Citizenship Card - Front',
                  style: AppTextStyles.heading4,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _citizenshipFront != null
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: _citizenshipFront != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _citizenshipFront!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload front photo',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Citizenship Back
                Text(
                  'Citizenship Card - Back',
                  style: AppTextStyles.heading4,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _citizenshipBack != null
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: _citizenshipBack != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _citizenshipBack!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload back photo',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your verification request will be reviewed by admin within 24-48 hours.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return PrimaryButton(
                      label: _isSubmitting || userProvider.isLoading
                          ? 'Submitting...'
                          : 'Submit Verification',
                      onPressed: (_isSubmitting || userProvider.isLoading)
                          ? null
                          : _submitVerification,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

