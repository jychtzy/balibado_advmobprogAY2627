import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import '../widgets/custom_text.dart';

// =====================================================================
// BONUS: the chat FloatingActionButton has been removed entirely — no
// more floatingActionButton, no more chat SnackBar stub, no more
// "hide while on Cart tab" logic (there's nothing left to hide). The
// bottom nav goes back to being the only navigation surface.
//
// Design: AppBar/BottomNavigationBar now come from the shared
// AppTheme (see constants/app_theme.dart) instead of a locally
// hardcoded _brandColor, so this screen automatically follows the
// light/dark theme instead of always forcing indigo.
// =====================================================================

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Index of the Cart tab, used only for the AppBar title now.
  static const int _cartIndex = 1;

  // Profile tab
  static const int _profileIndex = 2;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _selectedIndex == 0
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                )
              : CustomText(
                  text: _selectedIndex == _cartIndex ? 'Cart' : 'Profile',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              // Settings icon now leads to settings screen
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: <Widget>[
            const ProductScreen(),
            const CartScreen(),
            // Profile screen - placeholder
            Center(
              child: CustomText(text: 'Profile', fontSize: 16.sp),
            ),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    // Profile tab - placeholder
    if (value == _profileIndex) return;

    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}