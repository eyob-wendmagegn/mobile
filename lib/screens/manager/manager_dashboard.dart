import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/models/user.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/providers/profile_provider.dart';
import 'package:waste_management_app/providers/theme_provider.dart';
import 'package:waste_management_app/screens/manager/collections_screen.dart';
import 'package:waste_management_app/screens/manager/manager_home_screen.dart';
import 'package:waste_management_app/screens/manager/settings_screen.dart';
import 'package:waste_management_app/screens/manager/users_screen.dart';
import 'package:waste_management_app/screens/user/user_dashboard.dart';
import 'package:waste_management_app/widgets/custom_switch_tile.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({Key? key}) : super(key: key);

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ManagerHomeScreen(),
    const CollectionsScreen(),
    const UsersScreen(),
    const ManagerSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set the user ID for the profile provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        profileProvider.setUserId(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          // Go to Home button
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserDashboard()),
              );
            },
            icon: const Icon(Icons.home, color: Colors.white),
            label:
                const Text('Go to Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
