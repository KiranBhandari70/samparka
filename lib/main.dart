import 'package:flutter/material.dart';
import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_shell.dart';
import 'presentation/pages/auth/auth_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/home/event_detail_page.dart';
import 'presentation/pages/groups/group_chat_page.dart';

void main() {
  runApp(const SamparkaApp());
}

class SamparkaApp extends StatelessWidget {
  const SamparkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashPage.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SplashPage.routeName:
            return MaterialPageRoute(
              builder: (_) => const SplashPage(),
            );
          case OnboardingPage.routeName:
            return MaterialPageRoute(
              builder: (_) => const OnboardingPage(),
            );
          case AuthPage.routeName:
            return MaterialPageRoute(
              builder: (_) => const AuthPage(),
            );
          case MainShell.routeName:
            return MaterialPageRoute(
              builder: (_) => const MainShell(),
            );
          case EventDetailPage.routeName:
            final args = settings.arguments as EventDetailArgs;
            return MaterialPageRoute(
              builder: (_) => EventDetailPage(event: args.event),
            );
          case GroupChatPage.routeName:
            final args = settings.arguments as GroupChatArgs;
            return MaterialPageRoute(
              builder: (_) => GroupChatPage(group: args.group),
            );
          case SettingsPage.routeName:
            return MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashPage(),
            );
        }
      },
    );
  }
}