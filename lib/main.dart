import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const SafeRouteRoot());
}

class SafeRouteRoot extends StatefulWidget {
  const SafeRouteRoot({super.key});

  @override
  State<SafeRouteRoot> createState() => _SafeRouteRootState();
}

class _SafeRouteRootState extends State<SafeRouteRoot> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeRoute AI',
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routes: {
        '/': (_) => const SplashScreen(),
        AuthScreen.routeName: (_) => const AuthScreen(),
        MainShell.routeName: (_) => MainShell(
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            ),
      },
    );
  }
}
