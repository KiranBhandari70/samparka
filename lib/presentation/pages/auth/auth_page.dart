import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../onboarding/onboarding_page.dart';
import '../../navigation/main_shell.dart';

class AuthPage extends StatefulWidget {
  final bool initialMode;

  const AuthPage({
    super.key,
    this.initialMode = true,
  });

  static const String routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialMode;
  }
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode(bool isLogin) {
    if (_isLogin == isLogin) return;
    setState(() => _isLogin = isLogin);
  }

  void _submit() {
    Navigator.of(context).pushReplacementNamed(MainShell.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? AppStrings.loginWelcomeBack : 'Join the Community';
    final buttonText = _isLogin ? 'Login' : 'Sign Up';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(120),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(120),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _AuthToggleButton(
                                label: 'Login',
                                isActive: _isLogin,
                                onTap: () => _toggleMode(true),
                              ),
                              _AuthToggleButton(
                                label: 'Sign Up',
                                isActive: !_isLogin,
                                onTap: () => _toggleMode(false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: AppStrings.emailPlaceholder,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: AppStrings.passwordPlaceholder,
                          ),
                        ),
                        if (_isLogin) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                AppStrings.forgotPassword,
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Icon(Icons.check_circle,
                                  size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Password must be at least 8 characters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        PrimaryButton(label: buttonText, onPressed: _submit),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Or Continue with',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SocialButton(
                          label: AppStrings.continueWithGoogle,
                          icon: Icons.g_mobiledata_rounded,
                          onTap: _submit,
                        ),
                        const SizedBox(height: 12),
                        _SocialButton(
                          label: AppStrings.continueWithPhone,
                          icon: Icons.phone_rounded,
                          onTap: _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.terms,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(
                          OnboardingPage.routeName,
                        ),
                    child: const Text('Back to Onboarding'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive
                ? const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


