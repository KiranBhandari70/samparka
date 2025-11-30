import 'package:flutter/material.dart';
import 'package:samparka/config/environment.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/services/admin_service.dart';

class AdminVerificationsPage extends StatefulWidget {
  const AdminVerificationsPage({super.key});

  static const String routeName = '/admin-verifications';

  @override
  State<AdminVerificationsPage> createState() => _AdminVerificationsPageState();
}

class _AdminVerificationsPageState extends State<AdminVerificationsPage> {
  List<Map<String, dynamic>> _pendingVerifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  Future<void> _loadPendingVerifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final verifications = await AdminService.instance.getPendingVerifications();
      setState(() {
        _pendingVerifications = verifications;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _reviewVerification(String userId, String action, {String? rejectionReason}) async {
    try {
      await AdminService.instance.reviewVerification(
        userId,
        action,
        rejectionReason: rejectionReason,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification ${action == 'approve' ? 'approved' : 'rejected'} successfully'),
          backgroundColor: action == 'approve' ? AppColors.accentGreen : AppColors.accentRed,
        ),
      );
      _loadPendingVerifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _showRejectionDialog(String userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reviewVerification(userId, 'reject', rejectionReason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Requests'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: AppTextStyles.body.copyWith(color: AppColors.accentRed),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPendingVerifications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _pendingVerifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 80,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pending verifications',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPendingVerifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _pendingVerifications.length,
                          itemBuilder: (context, index) {
                            final user = _pendingVerifications[index];
                            final verificationData = user['verificationData'] as Map<String, dynamic>?;
                            final userId = user['_id'] ?? user['id'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: user['avatarUrl'] != null
                                            ? NetworkImage(
                                                user['avatarUrl'].toString().startsWith('http')
                                                    ? user['avatarUrl'].toString()
                                                    : '${Environment.apiBaseUrl}${user['avatarUrl']}',
                                              )
                                            : null,
                                        child: user['avatarUrl'] == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'] ?? 'Unknown',
                                              style: AppTextStyles.heading4,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user['email'] ?? '',
                                              style: AppTextStyles.caption,
                                            ),
                                            if (verificationData?['phoneNumber'] != null)
                                              Text(
                                                'Phone: ${verificationData!['phoneNumber']}',
                                                style: AppTextStyles.caption,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Front',
                                              style: AppTextStyles.caption.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () {
                                                final url = verificationData?['citizenshipFrontUrl'];
                                                if (url != null) {
                                                  _showImageDialog(
                                                    url.toString().startsWith('http')
                                                        ? url.toString()
                                                        : '${Environment.apiBaseUrl}$url',
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceVariant,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.border),
                                                ),
                                                child: verificationData?['citizenshipFrontUrl'] != null
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(11),
                                                        child: Image.network(
                                                          verificationData!['citizenshipFrontUrl']
                                                                  .toString()
                                                                  .startsWith('http')
                                                              ? verificationData['citizenshipFrontUrl'].toString()
                                                              : '${Environment.apiBaseUrl}${verificationData['citizenshipFrontUrl']}',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const Icon(Icons.broken_image);
                                                          },
                                                        ),
                                                      )
                                                    : const Icon(Icons.image, size: 40),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Back',
                                              style: AppTextStyles.caption.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () {
                                                final url = verificationData?['citizenshipBackUrl'];
                                                if (url != null) {
                                                  _showImageDialog(
                                                    url.toString().startsWith('http')
                                                        ? url.toString()
                                                        : '${Environment.apiBaseUrl}$url',
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceVariant,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.border),
                                                ),
                                                child: verificationData?['citizenshipBackUrl'] != null
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(11),
                                                        child: Image.network(
                                                          verificationData!['citizenshipBackUrl']
                                                                  .toString()
                                                                  .startsWith('http')
                                                              ? verificationData['citizenshipBackUrl'].toString()
                                                              : '${Environment.apiBaseUrl}${verificationData['citizenshipBackUrl']}',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const Icon(Icons.broken_image);
                                                          },
                                                        ),
                                                      )
                                                    : const Icon(Icons.image, size: 40),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _reviewVerification(userId, 'approve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.accentGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, size: 20),
                                              SizedBox(width: 8),
                                              Text('Approve'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _showRejectionDialog(userId),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.accentRed,
                                            side: const BorderSide(color: AppColors.accentRed),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cancel, size: 20),
                                              SizedBox(width: 8),
                                              Text('Reject'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('View Document'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('Failed to load image'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

