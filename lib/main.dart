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
///
/// Author: Sales Management Module Implementation
/// Course: CST2335 - Mobile Graphical Interface Programming
/// Term: Fall 2024

import 'package:flutter/material.dart';
import 'pages/sales_page.dart';

/// Application entry point
/// Initializes and runs the Flutter application
///
/// This function is called when the app starts and creates the root widget
/// that contains the entire application widget tree.
void main() {
  runApp(MyApp());
}

/// Root application widget
/// Configures the MaterialApp with routes, theme, and initial settings
///
/// Project Requirements Addressed:
/// * Application structure and navigation setup
/// * Professional interface design (Requirement 10)
/// * Team collaboration support through route definitions (Requirement 9)
/// * Consistent theme across all modules
class MyApp extends StatelessWidget {
  /// Builds the root widget of the application
  /// Configures MaterialApp with theme, routes, and initial page
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
      ///
      /// Current routes:
      /// * '/' - Main home page with navigation to all modules
      /// * '/sales' - Sales management module (fully implemented)
      ///
      /// TODO: Team members will add these routes:
      /// * '/customers' - Customer management module (Team member 1)
      /// * '/cars' - Car management module (Team member 2)
      /// * '/dealerships' - Dealership management module (Team member 3)
      routes: {
        // Main landing page - central navigation hub
        '/': (context) => HomePage(),

        // Sales management module - complete implementation
        '/sales': (context) => SalesPage(),

        // Multi-language testing page for Requirement 8
        '/language-test': (context) => LanguageTestingWidget(),

        // TODO: Add routes for other team members
        // '/customers': (context) => CustomerPage(),
        // '/cars': (context) => CarPage(),
        // '/dealerships': (context) => DealershipPage(),
      },

      /// Handle unknown routes gracefully
      /// Returns user to home page if they navigate to non-existent route
      /// Prevents app crashes from invalid navigation attempts
      ///
      /// [settings] - Route settings for the unknown route
      ///
      /// Returns: MaterialPageRoute that navigates to HomePage
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      },
    );
  }
}

/// Home page widget - Main navigation hub for the application
/// Displays welcome message and navigation buttons to all modules
///
/// Project Requirements Addressed:
/// * Main page that shows once application is launched
/// * Navigation buttons to launch each team member's module
/// * Professional interface design (Requirement 10)
/// * Central hub for team collaboration (Requirement 9)
class HomePage extends StatelessWidget {
  /// Builds the home page interface
  /// Creates welcome screen with navigation buttons for each module
  ///
  /// [context] - Build context for accessing theme and navigation
  ///
  /// Returns: Scaffold widget containing the home page layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with application title
      appBar: AppBar(
        title: Text('Car Management System'),
        backgroundColor: Colors.blue,
      ),

      // Main body with scrollable content to prevent overflow
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome header section
            _buildWelcomeHeader(),

            SizedBox(height: 40),

            // Navigation buttons for each module
            _buildNavigationButtons(context),

            SizedBox(height: 40),

            // Project information footer
            _buildProjectInfo(),

            // Extra space at bottom to ensure all content is accessible
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds the welcome header with app icon and title
  /// Creates an attractive introduction to the application
  ///
  /// Returns: Widget containing welcome header elements
  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        // App icon
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

        // Main title
        Text(
          'Car Management System',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8),

        // Subtitle
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
  /// Each button navigates to a different team member's implementation
  ///
  /// [context] - Build context for navigation operations
  ///
  /// Returns: Widget containing all navigation buttons
  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        // Section title
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
          title: '🚀 Sales Management',
          subtitle: 'Manage sales records and transactions - READY!',
          route: '/sales',
          color: Colors.red,
          isImplemented: true,
        ),

        SizedBox(height: 16),

        // Multi-language testing button (for Requirement 8 verification)
        Card(
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
                            'Test American vs British English differences',
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
                              'REQUIREMENT 8 DEMO',
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
        ),

        SizedBox(height: 16),

        // Customer Management button (placeholder)
        _buildModuleButton(
          context: context,
          title: 'Customer Management',
          subtitle: 'Manage customer information and records',
          route: '/customers',
          color: Colors.green,
          isImplemented: false,
        ),

        SizedBox(height: 16),

        // Car Management button (placeholder)
        _buildModuleButton(
          context: context,
          title: 'Car Management',
          subtitle: 'Manage car inventory and specifications',
          route: '/cars',
          color: Colors.orange,
          isImplemented: false,
        ),

        SizedBox(height: 16),

        // Dealership Management button (placeholder)
        _buildModuleButton(
          context: context,
          title: 'Dealership Management',
          subtitle: 'Manage dealership locations and information',
          route: '/dealerships',
          color: Colors.purple,
          isImplemented: false,
        ),
      ],
    );
  }

  /// Creates a styled navigation button for a specific module
  /// Handles navigation and provides visual feedback for implementation status
  ///
  /// [context] - Build context for navigation and snackbar display
  /// [title] - Display title for the module
  /// [subtitle] - Descriptive text for the module functionality
  /// [route] - Navigation route path for the module
  /// [color] - Theme color for the button
  /// [isImplemented] - Whether this module has been implemented
  ///
  /// Returns: Widget containing the styled navigation button
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
            // Navigate to implemented module
            Navigator.pushNamed(context, route);
          } else {
            // Show placeholder message for unimplemented modules
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
                // Module icon
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

                // Module information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Module title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isImplemented ? color : Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 4),

                      // Module description
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),

                      // Implementation status
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

                // Navigation arrow
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
  /// Returns relevant Material Design icon for visual consistency
  ///
  /// [title] - Module title to determine icon
  ///
  /// Returns: IconData for the appropriate icon
  IconData _getModuleIcon(String title) {
    if (title.contains('Sales')) return Icons.attach_money;
    if (title.contains('Customer')) return Icons.people;
    if (title.contains('Car')) return Icons.directions_car;
    if (title.contains('Dealership')) return Icons.business;
    return Icons.dashboard;
  }

  /// Builds project information footer
  /// Displays course and project details
  ///
  /// Returns: Widget containing project information
  Widget _buildProjectInfo() {
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
  /// Displays snackbar notification when user tries to access unfinished modules
  ///
  /// [context] - Build context for showing snackbar
  /// [moduleName] - Name of the module that was clicked
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

/// Multi-language testing widget for Requirement 8 demonstration
/// Shows American vs British English differences
///
/// Project Requirements Addressed:
/// * Requirement 8: Multi-language support (American vs British English)
/// * Professional interface design
/// * Educational demonstration of language differences
class LanguageTestingWidget extends StatefulWidget {
  @override
  _LanguageTestingWidgetState createState() => _LanguageTestingWidgetState();
}

class _LanguageTestingWidgetState extends State<LanguageTestingWidget> {
  bool isAmericanEnglish = true;

  /// Gets the appropriate text based on selected language variant
  ///
  /// [american] - American English version
  /// [british] - British English version
  ///
  /// Returns: String appropriate for current language setting
  String _getLocalizedText(String american, String british) {
    return isAmericanEnglish ? american : british;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Language Demo'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language Variant Selection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isAmericanEnglish,
                          onChanged: (value) => setState(() => isAmericanEnglish = value!),
                        ),
                        Text('American English 🇺🇸'),
                        SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: isAmericanEnglish,
                          onChanged: (value) => setState(() => isAmericanEnglish = value!),
                        ),
                        Text('British English 🇬🇧'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Language differences demonstration
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language Differences Example',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),

                      _buildLanguageExample('Color/Colour:',
                          _getLocalizedText('Color', 'Colour')),
                      _buildLanguageExample('Center/Centre:',
                          _getLocalizedText('Center', 'Centre')),
                      _buildLanguageExample('Favorite/Favourite:',
                          _getLocalizedText('Favorite', 'Favourite')),
                      _buildLanguageExample('Organize/Organise:',
                          _getLocalizedText('Organize', 'Organise')),
                      _buildLanguageExample('License/Licence:',
                          _getLocalizedText('License', 'Licence')),

                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Text(
                          'This demonstrates Requirement 8: Supporting multiple language variants. '
                              'The application can switch between American and British English spelling conventions.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a language example row
  ///
  /// [label] - Description of the difference
  /// [value] - Current value based on language selection
  ///
  /// Returns: Widget showing the language example
  Widget _buildLanguageExample(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}