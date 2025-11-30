import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../pages/events/add_event_page.dart';
import '../pages/explore/explore_page.dart';
import '../pages/groups/groups_list_page.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile_page.dart';
import 'admin_shell.dart';
import 'business_shell.dart';

class MainShell extends StatefulWidget {
  final UserModel user;

  const MainShell({
    super.key,
    required this.user,
  });

  static const String routeName = '/home';

  /// Helper to navigate to home tab
  static void navigateToHome(BuildContext? context) {
    // This is handled by the appropriate shell now
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _viewMode = 'default';

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewMode = prefs.getString('profile_view_mode') ?? 'default';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Route to appropriate shell based on user role and view mode
    if (widget.user.role == 'admin') {
      return AdminShell(user: widget.user);
    } else if (widget.user.role == 'business' && _viewMode != 'normal') {
      return BusinessShell(user: widget.user);
    } else {
      return _NormalUserShell(user: widget.user);
    }
  }
}

class _NormalUserShell extends StatefulWidget {
  final UserModel user;

  const _NormalUserShell({required this.user});

  @override
  State<_NormalUserShell> createState() => _NormalUserShellState();
}

class _NormalUserShellState extends State<_NormalUserShell> {
  int _currentIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    // Check view mode preference for business users
    final prefs = await SharedPreferences.getInstance();
    final viewMode = prefs.getString('profile_view_mode') ?? 'default';
    
    // Pages for normal users
    Widget profilePage = ProfilePage(user: widget.user);

    if (mounted) {
      setState(() {
        _pages = [
          const HomePage(),
          const ExplorePage(),
          const AddEventPage(),
          const GroupsListPage(),
          profilePage,
        ];
      });
    }
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.tabBarInactive,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.map_rounded, 'Explore', 1),
            const BottomNavigationBarItem(
              icon: _PlusIcon(),
              label: 'Create',
            ),
            _buildNavItem(Icons.groups_rounded, 'Groups', 3),
            _buildNavItem(Icons.person_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }
}

class _PlusIcon extends StatelessWidget {
  const _PlusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
