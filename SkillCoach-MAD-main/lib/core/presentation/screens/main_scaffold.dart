import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(context, index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(PhosphorIcons.house()),
                  activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(PhosphorIcons.chats()),
                  activeIcon: Icon(PhosphorIcons.chats(PhosphorIconsStyle.fill)),
                  label: 'Coach',
                ),
                BottomNavigationBarItem(
                  icon: Icon(PhosphorIcons.sparkle()),
                  activeIcon: Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill)),
                  label: 'Skills',
                ),
                BottomNavigationBarItem(
                  icon: Icon(PhosphorIcons.user()),
                  activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

