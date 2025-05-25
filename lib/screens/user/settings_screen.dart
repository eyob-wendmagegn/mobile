import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/providers/profile_provider.dart';
import 'package:waste_management_app/providers/theme_provider.dart';
import 'package:waste_management_app/screens/user/profile_edit_screen.dart';
import 'package:waste_management_app/widgets/custom_switch_tile.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view settings')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    backgroundImage: profileProvider.hasProfileImage()
                        ? profileProvider.getProfileImage()
                        : null,
                    child: !profileProvider.hasProfileImage()
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(
                            user: user,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 45),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // App Settings Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Dark Mode Toggle
            CustomSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              icon: Icons.dark_mode,
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setDarkMode(value);
              },
            ),

            // Notifications Toggle
            CustomSwitchTile(
              title: 'Notifications',
              subtitle: 'Enable push notifications',
              icon: Icons.notifications,
              value:
                  true, // This would be connected to a real notification service
              onChanged: (value) {
                // In a real app, this would toggle notification settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Language Selection
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.language, color: Colors.white),
              ),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // In a real app, this would open language selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Language selection not implemented in this demo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const Divider(),

            // About Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // About App
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.info, color: Colors.white),
              ),
              title: const Text('About App'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // In a real app, this would open about page
                showAboutDialog(
                  context: context,
                  applicationName: 'Waste Management App',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.recycling,
                      size: 50, color: Colors.green),
                  children: [
                    const Text(
                      'A sustainable waste management solution to help reduce waste and promote recycling.',
                    ),
                  ],
                );
              },
            ),

            // Terms & Conditions
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.description, color: Colors.white),
              ),
              title: const Text('Terms & Conditions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // In a real app, this would open terms page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Terms & Conditions not implemented in this demo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Privacy Policy
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.privacy_tip, color: Colors.white),
              ),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // In a real app, this would open privacy policy page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Privacy Policy not implemented in this demo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
