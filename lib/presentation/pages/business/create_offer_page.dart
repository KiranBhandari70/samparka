import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/offer_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/primary_button.dart';

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  static const String routeName = '/create-offer';

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _pointsRequiredController = TextEditingController();
  final _termsController = TextEditingController();
  final _maxRedemptionsController = TextEditingController();

  String _selectedCategory = 'food';
  String _selectedDiscountType = 'percentage';
  DateTime? _validUntil;
  File? _imageFile;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'food', 'label': 'Food & Dining'},
    {'value': 'retail', 'label': 'Retail & Shopping'},
    {'value': 'entertainment', 'label': 'Entertainment'},
    {'value': 'services', 'label': 'Services'},
    {'value': 'health', 'label': 'Health & Wellness'},
    {'value': 'travel', 'label': 'Travel & Tourism'},
    {'value': 'others', 'label': 'Others'},
  ];

  final List<Map<String, String>> _discountTypes = [
    {'value': 'percentage', 'label': 'Percentage Off'},
    {'value': 'fixed_amount', 'label': 'Fixed Amount Off'},
    {'value': 'free_item', 'label': 'Free Item'},
    {'value': 'buy_one_get_one', 'label': 'Buy 1 Get 1'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _businessNameController.dispose();
    _discountValueController.dispose();
    _pointsRequiredController.dispose();
    _termsController.dispose();
    _maxRedemptionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _validUntil = picked;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _businessNameController.clear();
    _discountValueController.clear();
    _pointsRequiredController.clear();
    _termsController.clear();
    _maxRedemptionsController.clear();
    _selectedCategory = 'food';
    _selectedDiscountType = 'percentage';
    _validUntil = null;
    _imageFile = null;
    _formKey.currentState?.reset();
    setState(() {});
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_validUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);

      if (kDebugMode) {
        print('Creating offer with userId: ${authProvider.currentUserId}');
      }

      final success = await offerProvider.createOffer(
        userId: authProvider.currentUserId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        businessName: _businessNameController.text.trim(),
        category: _selectedCategory,
        discountType: _selectedDiscountType,
        discountValue: double.parse(_discountValueController.text),
        pointsRequired: int.parse(_pointsRequiredController.text),
        validUntil: _validUntil!,
        imageFile: _imageFile,
        termsAndConditions: _termsController.text.trim().isNotEmpty 
            ? _termsController.text.trim() 
            : null,
        maxRedemptions: _maxRedemptionsController.text.trim().isNotEmpty 
            ? int.parse(_maxRedemptionsController.text.trim()) 
            : null,
      );

      if (!mounted) return;

      if (success) {
        if (kDebugMode) {
          print('Offer created successfully');
        }
        
        // Reset loading state first
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offer created successfully!'),
              backgroundColor: AppColors.accentGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Wait a bit for the snackbar to show
        await Future.delayed(const Duration(milliseconds: 1200));
        
        if (mounted) {
          // Check if we can pop (i.e., we were navigated to, not in a tab)
          final canPop = Navigator.of(context).canPop();
          
          if (canPop) {
            // Pop with success result so the previous page can refresh
            Navigator.of(context).pop(true);
            if (kDebugMode) {
              print('Navigated back from create offer page with success');
            }
          } else {
            // We're in a tab, so just reset the form
            _resetForm();
            if (kDebugMode) {
              print('Offer created, form reset (in tab view)');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Offer creation failed: ${offerProvider.error}');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(offerProvider.error ?? 'Failed to create offer'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 3),
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Exception creating offer: $e');
        print('Stack trace: $stackTrace');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating offer: ${e.toString()}'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Offer'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image upload
              _buildImageUpload(),
              const SizedBox(height: 24),

              // Basic info
              Text('Basic Information', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Offer Title',
                  hintText: 'e.g., 20% Off All Items',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter offer title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your offer...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  hintText: 'Your business name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['value'],
                    child: Text(category['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Discount details
              Text('Discount Details', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedDiscountType,
                decoration: const InputDecoration(
                  labelText: 'Discount Type',
                ),
                items: _discountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiscountType = value!;
                    // Set default values for special offer types
                    if (value == 'free_item' || value == 'buy_one_get_one') {
                      _discountValueController.text = '1';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_selectedDiscountType != 'free_item' && _selectedDiscountType != 'buy_one_get_one')
                TextFormField(
                  controller: _discountValueController,
                  decoration: InputDecoration(
                    labelText: _selectedDiscountType == 'percentage' 
                        ? 'Discount Percentage' 
                        : 'Discount Amount (NPR)',
                    hintText: _selectedDiscountType == 'percentage' ? '20' : '500',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter discount value';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    if (_selectedDiscountType == 'percentage' && number > 100) {
                      return 'Percentage cannot exceed 100';
                    }
                    return null;
                  },
                ),
              
              if (_selectedDiscountType == 'free_item' || _selectedDiscountType == 'buy_one_get_one')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDiscountType == 'free_item' 
                        ? 'Customers will get a free item with this offer'
                        : 'Customers will get buy 1 get 1 offer',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pointsRequiredController,
                decoration: const InputDecoration(
                  labelText: 'Points Required',
                  hintText: '500',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter points required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Validity and limits
              Text('Validity & Limits', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              // Expiry date
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textMuted.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _validUntil != null 
                              ? 'Expires: ${_validUntil!.day}/${_validUntil!.month}/${_validUntil!.year}'
                              : 'Select expiry date',
                          style: AppTextStyles.body.copyWith(
                            color: _validUntil != null ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _maxRedemptionsController,
                decoration: const InputDecoration(
                  labelText: 'Max Redemptions (Optional)',
                  hintText: 'Leave empty for unlimited',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid positive number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _termsController,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions (Optional)',
                  hintText: 'Enter terms and conditions...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isLoading ? 'Creating...' : 'Create Offer',
                  onPressed: _isLoading ? null : _createOffer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Offer Image', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textMuted.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add image',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
