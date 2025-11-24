import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/user_model.dart';
import '../pages/add_event/add_event_page.dart';
import '../pages/explore/explore_page.dart';
import '../pages/groups/groups_list_page.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile_page.dart';

class MainShell extends StatefulWidget {
  final UserModel user;

  const MainShell({
    super.key,
    required this.user,
  });

  static const String routeName = '/home';

  /// Helper to navigate to home tab
  static void navigateToHome(BuildContext? context) {
    if (context != null) {
      final state = context.findAncestorStateOfType<_MainShellState>();
      state?.switchToTab(0);
    }
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Pages that may use the logged-in user
    _pages = [
      const HomePage(),
      const ExplorePage(),
      const AddEventPage(),
      const GroupsListPage(),
      ProfilePage(user: widget.user),
    ];
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: _PlusIcon(),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlusIcon extends StatelessWidget {
  const _PlusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
