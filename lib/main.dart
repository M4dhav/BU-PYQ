import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'privacy_policy.dart';
import 'widgets/pdf_viewer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final colorValue = prefs.getInt('accent_color');
      if (colorValue != null) {
        _accentColor = Color(colorValue);
      }
      
      final themeIndex = prefs.getInt('theme_mode');
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      }
    });
  }

  Future<void> _changeAccentColor(Color color) async {
    setState(() {
      _accentColor = color;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
  }

  Future<void> _toggleTheme() async {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        final brightness = MediaQuery.platformBrightnessOf(context);
        _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BU Scholar',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        cardTheme: const CardThemeData(surfaceTintColor: Colors.white),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => HomePage(
              title: 'Previous Year Question Papers',
              themeMode: _themeMode,
              onThemeToggle: _toggleTheme,
              onAccentColorChange: _changeAccentColor,
              currentAccentColor: _accentColor,
            ),
          );
        }
        if (settings.name == '/pdf_viewer') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => const PdfViewer(),
          );
        }
        if (settings.name == '/privacy-policy') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => const PrivacyPolicyPage(),
          );
        }
        return null;
      },
    );
  }
}
