import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/core/assets/app_icons.dart';
import 'package:kifiya/core/theme/app_theme.dart';

class BasePage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BasePage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/accountsPage')) {
      currentIndex = 1;
    } else if (location.startsWith('/transactionsPage')) {
      currentIndex = 2;
    } else if (location.startsWith('/profilePage')) {
      currentIndex = 3;
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: AppTheme.textColorDark),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        selectedItemColor: AppTheme.textColorDark,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        onTap: (index) {
          navigationShell.goBranch(index);
        },

        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(AppIcons.homeIcon, 20, currentIndex == 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(AppIcons.cardsIcon, 20, currentIndex == 1),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(AppIcons.transactionsIcon, 25, currentIndex == 2),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(AppIcons.profileIcon, 25, currentIndex == 3),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath, double height, bool isSelected) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isSelected ? AppTheme.textColorDark : Colors.black.withOpacity(0.6),
        BlendMode.srcIn,
      ),
      child: Image.asset(assetPath, height: height),
    );
  }
}
