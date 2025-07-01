import 'package:employee_attendance/screens/attendance_screen.dart';
import 'package:employee_attendance/screens/calender_screen.dart';
import 'package:employee_attendance/screens/profile_screen.dart';
import 'package:employee_attendance/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:employee_attendance/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<NavigationItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _navigationItems = [
    NavigationItem(
      icon: FontAwesomeIcons.solidCalendarDays,
      label: Strings.calendar,
      screen: const CalenderScreen(),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.check,
      label: Strings.attendance,
        screen: Consumer<AuthService>(
          builder: (context, authService, child) {
            return AttendanceScreen(
              userPhotoPath: authService.userPhotoPath,
            );
          },
        ),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.solidUser,
      label: Strings.profile,
      screen: const ProfileScreen(),
    ),
  ];
  }

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navigationItems.length,
            (index) => _buildNavItem(index, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ThemeData theme) {
    final item = _navigationItems[index];
    final isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              item.icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
