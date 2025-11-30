import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/colors.dart';
import '../../data/models/user_model.dart';
import '../pages/business/business_profile_page.dart';
import '../pages/business/create_offer_page.dart';

class BusinessShell extends StatefulWidget {
  final UserModel user;

  const BusinessShell({
    super.key,
    required this.user,
  });

  static const String routeName = '/business-home';

  @override
  State<BusinessShell> createState() => _BusinessShellState();
}

class _BusinessShellState extends State<BusinessShell> {
  int _currentIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    // Check view mode preference
    final prefs = await SharedPreferences.getInstance();
    final viewMode = prefs.getString('profile_view_mode') ?? 'default';
    
    // Create pages based on view mode
    Widget profilePage;
    if (viewMode == 'normal') {
      // Show normal profile page if user switched to normal view
      profilePage = BusinessProfilePage(user: widget.user);
    } else {
      // Default business profile page
      profilePage = BusinessProfilePage(user: widget.user);
    }

    if (mounted) {
      setState(() {
        _pages = [
          profilePage,
          const CreateOfferPage(),
        ];
      });
    }
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
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFB347),
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
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_rounded),
              label: 'Create Offer',
            ),
          ],
        ),
      ),
    );
  }
}

