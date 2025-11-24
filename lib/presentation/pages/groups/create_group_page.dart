import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../data/models/category_model.dart';
import '../../../provider/group_provider.dart';
import '../../widgets/primary_button.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});
  static const String routeName = '/create-group';

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordController = TextEditingController();
  final List<String> _keywords = [];
  EventCategory? _selectedCategory;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Music'),
    CategoryModel(id: '2', name: 'Tech'),
    CategoryModel(id: '3', name: 'Sports'),
    CategoryModel(id: '4', name: 'Food'),
    CategoryModel(id: '5', name: 'Art'),
    CategoryModel(id: '6', name: 'Wellness'),
    CategoryModel(id: '7', name: 'Social'),
    CategoryModel(id: '8', name: 'Others'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final raw = _keywordController.text.trim().toLowerCase();
    final keyword = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (keyword.isEmpty) return;
    if (_keywords.contains(keyword)) return;
    setState(() {
      _keywords.add(keyword);
      _keywordController.clear();
    });
  }

  String _generateKeyword(String name) {
    var keyword = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (keyword.isEmpty) keyword = 'group';
    if (keyword.length > 10) keyword = keyword.substring(0, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.substring(timestamp.length - 4);
    return '$keyword$suffix';
  }

  Future<void> _pickImage() async {
    try {
      final hasPermission = await PermissionHelper.requestImagePermission();
      if (!hasPermission) return;

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_keywords.isEmpty) _keywords.add(_generateKeyword(_nameController.text));
    setState(() => _isLoading = true);

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final groupData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'keywords': _keywords,
        if (_selectedCategory != null) 'category': _selectedCategory!.label,
      };
      final group = await groupProvider.createGroup(groupData, imageFile: _selectedImage);
      if (!mounted) return;

      if (group != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!'), backgroundColor: Colors.green),
        );
        await groupProvider.loadGroups();
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(groupProvider.error ?? 'Failed to create group'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Create Group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UploadPlaceholder(onTap: _pickImage, selectedImage: _selectedImage),
                const SizedBox(height: 24),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Group Name', hintText: 'Enter group name'), validator: (v) => v == null || v.isEmpty ? 'Group name is required' : null),
                const SizedBox(height: 24),
                Text('Category', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _categories.map((c) => _CategoryChip(label: c.name, isSelected: _selectedCategory == EventCategoryX.fromString(c.name), onTap: () => setState(() => _selectedCategory = EventCategoryX.fromString(c.name)))).toList(),
                ),
                const SizedBox(height: 24),
                TextFormField(controller: _descriptionController, maxLines: 5, decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe your group...')),
                const SizedBox(height: 24),
                Text('Keywords', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _keywordController, decoration: const InputDecoration(hintText: 'Add a keyword (e.g., hiking)'), onSubmitted: (_) => _addKeyword())),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: _addKeyword, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Add')),
                  ],
                ),
                const SizedBox(height: 12),
                if (_keywords.isEmpty)
                  Text('Add at least one keyword so others can discover your group.', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted))
                else
                  Wrap(spacing: 8, runSpacing: 8, children: _keywords.map((k) => Chip(label: Text(k), deleteIcon: const Icon(Icons.close), onDeleted: () => setState(() => _keywords.remove(k)))).toList()),
                const SizedBox(height: 32),
                Consumer<GroupProvider>(builder: (context, provider, child) => SizedBox(width: double.infinity, child: PrimaryButton(label: 'Create Group', onPressed: (_isLoading || provider.isLoading) ? null : _submit))),
                if (_isLoading) const Padding(padding: EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final File? selectedImage;
  const _UploadPlaceholder({required this.onTap, this.selectedImage});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 2)),
        child: selectedImage != null
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 140))
            : Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.cloud_upload_rounded, size: 40, color: AppColors.textMuted), SizedBox(height: 8), Text('Upload group image', style: TextStyle(color: AppColors.textMuted))])),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: isSelected ? AppColors.primary : AppColors.border)),
        child: Text(label, style: AppTextStyles.chip.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}
