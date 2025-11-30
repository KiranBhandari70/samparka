import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/user_provider.dart';
import '../../../provider/auth_provider.dart';

class BusinessDetailsFormPage extends StatefulWidget {
  const BusinessDetailsFormPage({super.key});

  static const String routeName = '/business-details-form';

  @override
  State<BusinessDetailsFormPage> createState() => _BusinessDetailsFormPageState();
}

class _BusinessDetailsFormPageState extends State<BusinessDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessWebsiteController = TextEditingController();

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessDescriptionController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessWebsiteController.dispose();
    super.dispose();
  }

  Future<void> _submitBusinessDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check again if business already exists
      final currentUser = authProvider.userModel;
      if (currentUser != null && currentUser.businessProfile != null && currentUser.businessProfile!.isNotEmpty) {
        throw Exception('You already have a business profile registered.');
      }

      // Create business profile data
      final businessData = {
        'businessName': _businessNameController.text.trim(),
        'businessType': _businessTypeController.text.trim(),
        'businessDescription': _businessDescriptionController.text.trim(),
        'businessAddress': _businessAddressController.text.trim(),
        'businessPhone': _businessPhoneController.text.trim(),
        'businessEmail': _businessEmailController.text.trim().isNotEmpty 
            ? _businessEmailController.text.trim() 
            : null,
        'businessWebsite': _businessWebsiteController.text.trim().isNotEmpty 
            ? _businessWebsiteController.text.trim() 
            : null,
      };

      // Update user role to business and save business details
      // The backend should create a BusinessProfile document and link it
      await userProvider.updateProfile({
        'role': 'business',
        'businessDetails': businessData,
      });

      // Refresh user data
      await authProvider.refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business details saved successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );

        // Navigate to business home (which will show business shell)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save business details: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.secondaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Complete Your Business Profile',
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your business details to access the business dashboard',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  hint: 'Enter your business name',
                  icon: Icons.business_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessTypeController,
                  label: 'Business Type',
                  hint: 'e.g., Restaurant, Retail, Service, etc.',
                  icon: Icons.category_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessDescriptionController,
                  label: 'Business Description',
                  hint: 'Describe your business',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessAddressController,
                  label: 'Business Address',
                  hint: 'Enter your business address',
                  icon: Icons.location_on_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessPhoneController,
                  label: 'Business Phone',
                  hint: 'Enter contact phone number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business phone is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessEmailController,
                  label: 'Business Email',
                  hint: 'Enter business email (optional)',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _businessWebsiteController,
                  label: 'Business Website',
                  hint: 'Enter website URL (optional)',
                  icon: Icons.language_rounded,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBusinessDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded),
                              const SizedBox(width: 8),
                              Text(
                                'Save & Continue',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.accentRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.accentRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

