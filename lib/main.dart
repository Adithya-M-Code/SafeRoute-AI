import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/report_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SafeRoute AI',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routes: {
              '/': (_) => const SplashScreen(),
              AuthScreen.routeName: (_) => const AuthScreen(),
              MainShell.routeName: (_) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}
