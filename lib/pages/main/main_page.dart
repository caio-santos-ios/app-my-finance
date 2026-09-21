import 'package:finance/pages/main/home_page.dart';
import 'package:finance/pages/main/operation_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.initialPage});

  final int initialPage;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _bottomNavIndex = 0;
  bool _isMenuOpen = false;

  late AnimationController _controller;

  final _pages = [HomePage()];
  final iconList = <IconData>[
    Icons.home_filled,
    Icons.swap_horiz,
    Icons.pie_chart,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
    _isMenuOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],

          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(color: Colors.black26),
              ),
            ),

          _buildSpeedDialItem(
            icon: FontAwesomeIcons.arrowUp,
            color: Colors.green,
            bottom: 40,
            leftOffset: -90,
            delay: 0.0,
            onPressed: () {
              _toggleMenu();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OperationPage(type: "income"),
                ),
              );
            },
          ),
          _buildSpeedDialItem(
            icon: FontAwesomeIcons.arrowRightArrowLeft,
            color: Colors.blue,
            bottom: 90,
            leftOffset: 0,
            delay: 0.1,
            onPressed: () {
              _toggleMenu();
            },
          ),
          _buildSpeedDialItem(
            icon: FontAwesomeIcons.arrowDown,
            color: Colors.red,
            bottom: 40,
            leftOffset: 90,
            delay: 0.2,
            onPressed: () {
              _toggleMenu();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OperationPage(type: "expense"),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: AnimatedRotation(
          turns: _isMenuOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 250),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        activeColor: Colors.amber,
        inactiveColor: Colors.grey,
      ),
    );
  }

  Widget _buildSpeedDialItem({
    required FaIconData icon,
    required Color color,
    required double bottom,
    required double leftOffset,
    required double delay,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: bottom,
      left: screenWidth / 2 - 28 + leftOffset,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          heroTag: icon.toString(),
          backgroundColor: color,
          elevation: 4,
          onPressed: onPressed,
          child: FaIcon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
