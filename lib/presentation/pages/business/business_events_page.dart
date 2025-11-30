import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';

class BusinessEventsPage extends StatelessWidget {
  const BusinessEventsPage({super.key});

  static const String routeName = '/business-events';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Sponsored Events'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'No sponsored events found',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}