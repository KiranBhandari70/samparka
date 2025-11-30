import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../core/constants/colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../../provider/event_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  static const String routeName = '/edit-event';

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late EventCategory? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  LocationResult? _autoLocation;
  bool _isDetectingLocation = false;
  String? _locationStatusMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _addressController = TextEditingController(text: widget.event.location?.placeName ?? '');
    _selectedCategory = widget.event.category;
    _selectedDate = widget.event.startsAt;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.startsAt);
    if (widget.event.location == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _detectCurrentLocation());
    } else {
      _locationStatusMessage = 'Using existing event location';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final hasPermission = await PermissionHelper.requestImagePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Please enable photo access in settings.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _detectCurrentLocation({bool forceUpdate = false}) async {
    setState(() {
      _isDetectingLocation = true;
      _locationStatusMessage = 'Detecting your location...';
    });

    final hasPermission = await PermissionHelper.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
          _locationStatusMessage = 'Location permission is required to auto-fill.';
        });
      }
      return;
    }

    final location = await LocationService.instance.detectCurrentLocation();
    if (!mounted) return;

    if (location != null) {
      setState(() {
        _autoLocation = location;
        final shouldWriteController =
            forceUpdate || _addressController.text.trim().isEmpty;
        if (shouldWriteController) {
          _addressController.text =
              location.addressLine ?? _formatCoordinates(location);
        }
        _locationStatusMessage = 'Location detected automatically';
        _isDetectingLocation = false;
      });
    } else {
      setState(() {
        _locationStatusMessage = 'Unable to detect current location';
        _isDetectingLocation = false;
      });
    }
  }

  String _formatCoordinates(LocationResult location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  Future<void> _submit() async {
    // Validate form
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine date and time
    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Build event data
    final eventData = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory!.name,
      'startsAt': eventDateTime.toIso8601String(),
    };

    final addressText = _addressController.text.trim();
    if (_autoLocation != null) {
      eventData['location'] = _autoLocation!.toGeoJson(
        overridePlaceName: addressText.isNotEmpty ? addressText : null,
        overrideAddress: addressText.isNotEmpty ? addressText : null,
      );
    } else if (addressText.isNotEmpty) {
      eventData['location'] = {
        'type': 'Point',
        'coordinates': widget.event.location?.coordinates ?? [0.0, 0.0],
        'placeName': addressText,
        'address': addressText,
      };
    }

    // Update event
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final success = await eventProvider.updateEvent(
      widget.event.id,
      eventData,
      imageFile: _selectedImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.error ?? 'Failed to update event'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UploadPlaceholder(
                      onTap: _pickImage,
                      selectedImage: _selectedImage,
                      existingImageUrl: widget.event.imageUrl,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Event Title',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Category',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: EventCategory.values
                          .map(
                            (category) => _CategoryChip(
                          label: category.label,
                          isSelected: _selectedCategory == category,
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: _PickerField(
                              label: 'Date',
                              value: _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: _PickerField(
                              label: 'Time',
                              value: _selectedTime == null
                                  ? 'Select time'
                                  : _selectedTime!.format(context),
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Address',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _autoLocation != null ? Icons.my_location : Icons.location_searching,
                            color: _autoLocation != null ? AppColors.accentGreen : AppColors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isDetectingLocation
                                  ? 'Detecting your location...'
                                  : _locationStatusMessage ??
                                      'Tap below to auto-detect this event\'s location.',
                              style: AppTextStyles.caption.copyWith(
                                color: _isDetectingLocation
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _isDetectingLocation
                                ? null
                                : () => _detectCurrentLocation(forceUpdate: true),
                            child: _isDetectingLocation
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Use current'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('Update Event'),
          ),
        ),
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final File? selectedImage;
  final String? existingImageUrl;

  const _UploadPlaceholder({
    required this.onTap,
    this.selectedImage,
    this.existingImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 140,
                ),
              )
            : existingImageUrl != null && existingImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      existingImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_upload_rounded,
              size: 40, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'Upload event image',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

