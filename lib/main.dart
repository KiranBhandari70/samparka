import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samparka/presentation/pages/settings/about_samparka.dart';
import 'package:samparka/presentation/pages/settings/help_center_screen.dart';

import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/permission_helper.dart';
import 'data/models/event_model.dart';
import 'data/models/group_model.dart';
import 'data/models/user_model.dart';
import 'provider/auth_provider.dart';
import 'provider/event_provider.dart';
import 'provider/group_provider.dart';
import 'provider/user_provider.dart';

import 'presentation/navigation/main_shell.dart';
import 'presentation/pages/auth/auth_page.dart';
import 'presentation/pages/auth/interests_selection_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/settings/privacy_security_screen.dart'; // New screen
import 'presentation/pages/settings/terms_privacy_screen.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/home/event_detail_page.dart';
import 'presentation/pages/groups/group_chat_page.dart';
import 'presentation/pages/groups/group_detail_page.dart';
import 'presentation/pages/groups/groups_list_page.dart';
import 'presentation/pages/groups/create_group_page.dart';
import 'presentation/pages/profile/edit_profile_page.dart';
import 'presentation/pages/edit_event/edit_event_page.dart';
import 'presentation/pages/events/ticket_purchase_page.dart';
import 'presentation/pages/rewards/rewards_dashboard_page.dart';
import 'presentation/pages/rewards/partner_businesses_page.dart';
import 'presentation/pages/admin/admin_dashboard_page.dart';
import 'presentation/pages/admin/admin_users_page.dart';
import 'presentation/pages/admin/admin_events_page.dart';
import 'presentation/pages/business/business_dashboard_page.dart';
import 'presentation/pages/business/business_events_page.dart';
import 'presentation/pages/business/business_partners_page.dart';
import 'presentation/pages/explore/category_explore_page.dart';

void main() {
  runApp(const SamparkaApp());
}

class SamparkaApp extends StatefulWidget {
  const SamparkaApp({super.key});

  @override
  State<SamparkaApp> createState() => _SamparkaAppState();
}

class _SamparkaAppState extends State<SamparkaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PermissionHelper.requestAllPermissions(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: SplashPage.routeName,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case SplashPage.routeName:
              return MaterialPageRoute(builder: (_) => const SplashPage());

            case OnboardingPage.routeName:
              return MaterialPageRoute(builder: (_) => const OnboardingPage());

            case AuthPage.routeName:
              return MaterialPageRoute(builder: (_) => const AuthPage());

            case MainShell.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final user = args?['user'] as UserModel?;
              return MaterialPageRoute(
                builder: (_) => user != null ? MainShell(user: user) : const SplashPage(),
              );

            case InterestsSelectionPage.routeName:
              return MaterialPageRoute(
                builder: (context) => InterestsSelectionPage(
                  onCompleted: () async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    await userProvider.updateInterests(userProvider.selectedInterests);
                    final currentUser = userProvider.currentUser;
                    if (currentUser != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => MainShell(user: currentUser),
                        ),
                      );
                    }
                  },
                ),
              );

            case EventDetailPage.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final event = args?['event'] as EventModel?;
              if (event == null) return MaterialPageRoute(builder: (_) => const SplashPage());
              return MaterialPageRoute(builder: (_) => EventDetailPage(event: event));

            case GroupChatPage.routeName:
              final args = settings.arguments as GroupChatArgs?;
              if (args == null) return MaterialPageRoute(builder: (_) => const SplashPage());
              return MaterialPageRoute(builder: (_) => GroupChatPage(group: args.group));

            case SettingsPage.routeName:
              return MaterialPageRoute(builder: (_) => const SettingsPage());

            case EditProfilePage.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final user = args?['user'] as UserModel?;
              return MaterialPageRoute(builder: (_) => EditProfilePage(user: user));

            case EditEventPage.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final event = args?['event'] as EventModel?;
              if (event == null) return MaterialPageRoute(builder: (_) => const SplashPage());
              return MaterialPageRoute(builder: (_) => EditEventPage(event: event));

            case TicketPurchasePage.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final event = args?['event'] as EventModel?;
              if (event == null) return MaterialPageRoute(builder: (_) => const SplashPage());
              return MaterialPageRoute(builder: (_) => TicketPurchasePage(event: event));

            case RewardsDashboardPage.routeName:
              return MaterialPageRoute(builder: (_) => const RewardsDashboardPage());

            case PartnerBusinessesPage.routeName:
              return MaterialPageRoute(builder: (_) => const PartnerBusinessesPage());

            case GroupDetailPage.routeName:
              final args = settings.arguments as Map<String, dynamic>?;
              final group = args?['group'] as GroupModel?;
              if (group == null) return MaterialPageRoute(builder: (_) => const SplashPage());
              return MaterialPageRoute(builder: (_) => GroupDetailPage(group: group));

            case GroupsListPage.routeName:
              return MaterialPageRoute(builder: (_) => const GroupsListPage());

            case CreateGroupPage.routeName:
              return MaterialPageRoute(builder: (_) => const CreateGroupPage());

            case AdminDashboardPage.routeName:
              return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

            case AdminUsersPage.routeName:
              return MaterialPageRoute(builder: (_) => const AdminUsersPage());

            case AdminEventsPage.routeName:
              return MaterialPageRoute(builder: (_) => const AdminEventsPage());

            case BusinessDashboardPage.routeName:
              return MaterialPageRoute(builder: (_) => const BusinessDashboardPage());

            case BusinessEventsPage.routeName:
              return MaterialPageRoute(builder: (_) => const BusinessEventsPage());

            case BusinessPartnersPage.routeName:
              return MaterialPageRoute(builder: (_) => const BusinessPartnersPage());

            case TermsPrivacyScreen.routeName:
              return MaterialPageRoute(builder: (_) => const TermsPrivacyScreen());

            case PrivacySecurityScreen.routeName:
              return MaterialPageRoute(builder: (_) => const PrivacySecurityScreen());

            case AboutSamparkaScreen.routeName:
              return MaterialPageRoute(builder: (_) => const AboutSamparkaScreen());

            case HelpCenterScreen.routeName:
              return MaterialPageRoute(builder: (_) => const HelpCenterScreen());


            default:
              return MaterialPageRoute(builder: (_) => const SplashPage());
          }
        },
      ),
    );
  }
}
