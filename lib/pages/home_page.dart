import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/task_list_screen.dart';
import '../screens/dashboard_screen.dart';
import '../services/theme_service.dart';
import '../constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // List of screens
  final List<Widget> _screens = [
    const TaskListScreen(),
    const DashboardScreen(),
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.task_alt,
      'label': 'Tasks',
      'tooltip': 'View and manage tasks',
    },
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'tooltip': 'View task statistics',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: _navigationItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item['icon']),
                  label: item['label'],
                  tooltip: item['tooltip'],
                );
              }).toList(),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          // Add theme toggle in app bar's actions
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: UIConstants.smallPadding),
                const Text('AI Todo App'),
              ],
            ),
            actions: [
              // Theme toggle
              Tooltip(
                message: themeService.themeMode == ThemeMode.light
                    ? 'Switch to Dark Mode'
                    : themeService.themeMode == ThemeMode.dark
                        ? 'Switch to System Mode'
                        : 'Switch to Light Mode',
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: UIConstants.shortAnimationDuration,
                    child: Icon(
                      themeService.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : themeService.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.brightness_auto,
                      key: ValueKey<ThemeMode>(themeService.themeMode),
                    ),
                  ),
                  onPressed: () {
                    themeService.toggleThemeMode();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
