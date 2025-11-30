import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../widgets/primary_button.dart';
import '../auth/auth_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.place_rounded,
      title: AppStrings.onboardingDiscoverTitle,
      description: AppStrings.onboardingDiscoverSubtitle,
    ),
    _OnboardingSlide(
      icon: Icons.groups_rounded,
      title: AppStrings.onboardingMeetTitle,
      description: AppStrings.onboardingMeetSubtitle,
    ),
    _OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      title: AppStrings.onboardingRewardsTitle,
      description: AppStrings.onboardingRewardsSubtitle,
    ),
  ];

  void _handleNext() {
    if (_currentIndex == _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 PageView with slides
            Expanded(
              flex: 12,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return _OnboardingSlideView(slide: slide);
                },
              ),
            ),

            // 🔹 Indicators + Buttons
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 10,
                          width: index == _currentIndex ? 32 : 10,
                          decoration: BoxDecoration(
                            color: index == _currentIndex
                                ? AppColors.primary
                                : AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _finish,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: PrimaryButton(
                            label: _currentIndex == _slides.length - 1
                                ? 'Start'
                                : 'Next',
                            onPressed: _handleNext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingSlideView extends StatelessWidget {
  final _OnboardingSlide slide;

  const _OnboardingSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Icon Section
        Expanded(
          flex: 12,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.onboardingGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(48),
              ),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),

        // 🔹 Text Section
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
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
