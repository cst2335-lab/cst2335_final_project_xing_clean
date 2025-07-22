/// Main entry point for the Car Management System Flutter application
/// CST2335 Final Project - Team Collaboration Project
///
/// This application implements a complete car management system with
/// four modules: Customer Management, Car Management, Dealership Management,
/// and Sales Management (fully implemented).
///
/// Project Requirements Addressed:
/// * Complete Flutter application with navigation
/// * Professional theme and styling (Requirement 10)
/// * Route-based navigation for team collaboration (Requirement 9)
/// * Multi-module architecture for team development
/// * Multi-language support (Requirement 8) - JSON-based Implementation
///
/// Author: Sales Management Module Implementation
/// Course: CST2335 - Mobile Graphical Interface Programming
/// Term: Fall 2024

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/sales_page.dart';
import 'l10n/app_localizations.dart';

/// Application entry point
/// Initializes and runs the Flutter application
void main() {
  runApp(MyApp());
}

/// Root application widget with JSON-based internationalization support
/// Configures the MaterialApp with routes, theme, and localization
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Static method to change language from anywhere in the app
  /// This allows child widgets to trigger language changes
  ///
  /// [context] - BuildContext to find the MyApp state
  /// [newLocale] - New locale to switch to
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Current locale for the application
  /// Defaults to American English as per project requirements
  Locale _locale = Locale('en', 'US');

  /// Change the application language
  /// Updates the locale and rebuilds the entire app
  ///
  /// [newLocale] - The new locale to switch to
  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  /// Builds the root widget of the application
  /// Configures MaterialApp with theme, routes, and internationalization
  ///
  /// [context] - Build context for the widget tree
  ///
  /// Returns: MaterialApp widget configured for the car management system
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application title shown in task switcher
      title: 'Car Management System - CST2335 Final Project',

      // Remove debug banner for professional appearance (Requirement 10)
      debugShowCheckedModeBanner: false,

      // Internationalization configuration (Requirement 8)
      // Support for American English and British English
      supportedLocales: const [
        Locale('en', 'US'), // American English
        Locale('en', 'GB'), // British English
      ],

      // Localization delegates - handles loading of translations
      localizationsDelegates: const [
        AppLocalizations.delegate,                    // Our custom localizations
        GlobalMaterialLocalizations.delegate,        // Material Design translations
        GlobalWidgetsLocalizations.delegate,         // Widget translations
        GlobalCupertinoLocalizations.delegate,       // Cupertino translations
      ],

      // Set current locale - this triggers translation loading
      locale: _locale,

      // Application theme configuration for consistent design
      theme: ThemeData(
        // Primary color scheme using Material Design
        primarySwatch: Colors.blue,

        // Visual density for optimal display across devices
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // AppBar theme for consistent header styling
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ElevatedButton theme for consistent button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Input decoration theme for consistent form styling
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        // Card theme for consistent card styling
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Initial route when application starts
      initialRoute: '/',

      /// Route definitions for navigation between modules
      /// Each team member adds their route here for integration
      routes: {
        // Main landing page - central navigation hub
        '/': (context) => HomePage(),

        // Sales management module - complete implementation
        '/sales': (context) => SalesPage(),

        // Multi-language testing page for Requirement 8 demonstration
        '/language-test': (context) => LanguageTestingWidget(),

        // TODO: Add routes for other team members
        // '/customers': (context) => CustomerPage(),
        // '/cars': (context) => CarPage(),
        // '/dealerships': (context) => DealershipPage(),
      },

      /// Handle unknown routes gracefully
      /// Returns user to home page if they navigate to non-existent route
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      },
    );
  }
}

/// Home page widget with JSON-based internationalization support
/// Displays welcome message and navigation buttons to all modules
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.appTitle ?? 'Car Management System'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeHeader(context),
            SizedBox(height: 40),
            _buildNavigationButtons(context),
            SizedBox(height: 40),
            _buildProjectInfo(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds the welcome header with app icon and localized title
  Widget _buildWelcomeHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.business_center,
            color: Colors.white,
            size: 40,
          ),
        ),
        SizedBox(height: 20),
        Text(
          localizations?.appTitle ?? 'Car Management System',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'CST2335 Final Project - Team Collaboration',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds navigation buttons for each application module
  Widget _buildNavigationButtons(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          'Select a Management Module',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),

        // Sales Management button (implemented)
        _buildModuleButton(
          context: context,
          title: localizations?.salesManagement ?? '🚀 Sales Management',
          subtitle: 'Manage sales records and transactions - READY!',
          route: '/sales',
          color: Colors.red,
          isImplemented: true,
        ),

        SizedBox(height: 16),

        // Multi-language testing button - demonstrates Requirement 8
        _buildLanguageTestButton(context),

        SizedBox(height: 16),

        // Other module buttons (placeholders for team members)
        _buildModuleButton(
          context: context,
          title: 'Customer List Page',
          subtitle: 'Add, view, update, and delete customers',
          route: '/customers',
          color: Colors.green,
          isImplemented: false,
        ),

        SizedBox(height: 16),

        _buildModuleButton(
          context: context,
          title: 'Car List Page',
          subtitle: 'Add new cars to company inventory and manage car details',
          route: '/cars',
          color: Colors.orange,
          isImplemented: false,
        ),

        SizedBox(height: 16),

        _buildModuleButton(
          context: context,
          title: 'Car Dealership List Page',
          subtitle: 'Add new dealerships and manage dealership locations',
          route: '/dealerships',
          color: Colors.purple,
          isImplemented: false,
        ),
      ],
    );
  }

  /// Builds the language testing button with proper internationalization demo
  Widget _buildLanguageTestButton(BuildContext context) {
    return Card(
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, '/language-test'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.purple.withValues(alpha: 0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Icon(Icons.language, color: Colors.purple, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌍 Multi-Language Testing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Test American vs British English with JSON files',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'REQUIREMENT 8 - JSON DEMO',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a styled navigation button for a specific module
  Widget _buildModuleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
    required bool isImplemented,
  }) {
    return Card(
      elevation: isImplemented ? 8 : 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isImplemented) {
            Navigator.pushNamed(context, route);
          } else {
            _showModuleNotImplemented(context, title);
          }
        },
        child: Container(
          decoration: isImplemented ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ) : null,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: isImplemented ? Border.all(color: color, width: 2) : null,
                  ),
                  child: Icon(
                    _getModuleIcon(title),
                    color: color,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isImplemented ? color : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!isImplemented) ...[
                        SizedBox(height: 4),
                        Text(
                          'Coming Soon - Team Member Implementation',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isImplemented ? color : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gets appropriate icon for each module type
  IconData _getModuleIcon(String title) {
    if (title.contains('Sales')) return Icons.attach_money;
    if (title.contains('Customer')) return Icons.people;
    if (title.contains('Car')) return Icons.directions_car;
    if (title.contains('Dealership')) return Icons.business;
    return Icons.dashboard;
  }

  /// Builds project information footer
  Widget _buildProjectInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'CST2335 Mobile Graphical Interface Programming',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Final Project - Fall 2024',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Shows placeholder message for unimplemented modules
  void _showModuleNotImplemented(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('$moduleName will be implemented by team members'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Multi-language testing widget with JSON-based internationalization
/// Demonstrates American vs British English differences using translation files
/// This satisfies Requirement 8 for multi-language support
class LanguageTestingWidget extends StatefulWidget {
  @override
  _LanguageTestingWidgetState createState() => _LanguageTestingWidgetState();
}

class _LanguageTestingWidgetState extends State<LanguageTestingWidget> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Language JSON Demo'),
        backgroundColor: Colors.purple,
        actions: [
          // Quick language switch buttons in app bar
          TextButton(
            onPressed: () => MyApp.setLocale(context, Locale('en', 'US')),
            child: Text('🇺🇸', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => MyApp.setLocale(context, Locale('en', 'GB')),
            child: Text('🇬🇧', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current language indicator
            _buildLanguageIndicator(context, localizations),

            SizedBox(height: 20),

            // Language switching section
            _buildLanguageSwitcher(context),

            SizedBox(height: 20),

            // Spelling differences demonstration
            _buildSpellingDifferences(context, localizations),

            SizedBox(height: 20),

            // JSON loading verification
            _buildJsonVerification(context, localizations),
          ],
        ),
      ),
    );
  }

  /// Build current language indicator
  Widget _buildLanguageIndicator(BuildContext context, AppLocalizations? localizations) {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.language, color: Colors.purple, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Language Variant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    localizations?.languageVariant ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build language switching controls
  Widget _buildLanguageSwitcher(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Switching (JSON-based)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => MyApp.setLocale(context, Locale('en', 'US')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('🇺🇸 American English'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => MyApp.setLocale(context, Locale('en', 'GB')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('🇬🇧 British English'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build spelling differences demonstration
  Widget _buildSpellingDifferences(BuildContext context, AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spelling Differences from JSON Files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            _buildSpellingComparison('Color/Colour:', localizations?.color ?? 'Loading...'),
            _buildSpellingComparison('Center/Centre:', localizations?.center ?? 'Loading...'),
            _buildSpellingComparison('Favorite/Favourite:', localizations?.favorite ?? 'Loading...'),
            _buildSpellingComparison('Organize/Organise:', localizations?.organize ?? 'Loading...'),
            _buildSpellingComparison('License/Licence:', localizations?.license ?? 'Loading...'),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                '✅ Requirement 8 completed: Multi-language support using JSON translation files. '
                    'American English (en.json) vs British English (en_GB.json) spelling differences demonstrated.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build spelling comparison row
  Widget _buildSpellingComparison(String label, String currentWord) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              currentWord,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build JSON verification section
  Widget _buildJsonVerification(BuildContext context, AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JSON Translation Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            Text('Translations loaded: ${localizations?.translationCount ?? 0}'),
            SizedBox(height: 8),
            Text('Current locale: ${Localizations.localeOf(context)}'),
            SizedBox(height: 8),
            Text('Files: assets/translations/en.json & en_GB.json'),

            SizedBox(height: 16),

            // Test some translations
            if (localizations != null) ...[
              Text('App Title: "${localizations.appTitle}"'),
              Text('Sales Management: "${localizations.salesManagement}"'),
              Text('Customer ID: "${localizations.customerID}"'),
              Text('Add Record: "${localizations.addRecord}"'),
            ],
          ],
        ),
      ),
    );
  }
}