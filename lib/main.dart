import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/providers/profile_provider.dart';
import 'package:waste_management_app/providers/theme_provider.dart';
import 'package:waste_management_app/screens/auth/login_screen.dart';
import 'package:waste_management_app/screens/manager/manager_dashboard.dart';
import 'package:waste_management_app/screens/user/user_dashboard.dart';
import 'package:waste_management_app/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Waste Management App',
      debugShowCheckedModeBanner: false, // This removes the DEBUG banner
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authProvider.currentUser == null
          ? const LoginScreen()
          : authProvider.currentUser!.email.contains('manager')
              ? const ManagerDashboard()
              : const UserDashboard(),
    );
  }
}
