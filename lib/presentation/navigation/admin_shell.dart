import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../data/models/user_model.dart';
import '../../provider/auth_provider.dart';
import '../pages/admin/admin_users_page.dart';
import '../pages/admin/admin_events_page.dart';
import '../pages/admin/admin_verifications_page.dart';
import '../pages/admin/admin_profile_page.dart';

class AdminShell extends StatefulWidget {
  final UserModel user;

  const AdminShell({
    super.key,
    required this.user,
  });

  static const String routeName = '/admin-home';

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.userModel ?? widget.user;
        final pages = [
          const AdminUsersPage(),
          const AdminEventsPage(),
          const AdminVerificationsPage(),
          AdminProfilePage(user: currentUser),
        ];
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.secondaryGradient[0],
          unselectedItemColor: AppColors.tabBarInactive,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_rounded),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_rounded),
              label: 'Verifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
        ));
      },
    );
  }
}

