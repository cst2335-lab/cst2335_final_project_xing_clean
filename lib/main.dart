import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/sales_page.dart'; // Import the complete sales page

/**
 * Main entry point of the Flutter application
 * Sets up the MaterialApp with routing configuration
 */
void main() {
  runApp(MyApp());
}

/**
 * Root widget of the application
 * Configures the app theme, routes, and initial page
 */
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Management System',
      debugShowCheckedModeBanner: false, // Remove debug banner for professional look

      // Application theme configuration
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // AppBar theme configuration
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),

        // ElevatedButton theme for consistent styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Input decoration theme for TextFields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),

      // Initial route when app starts
      initialRoute: '/',

      /**
       * Route definitions for navigation between pages
       * Each team member implements their own page and adds route here
       *
       * Route Structure:
       * '/' - Main home page with navigation buttons
       * '/sales' - Sales management page (your implementation)
       * '/customers' - Customer management page (Team member 1)
       * '/cars' - Car management page (Team member 2)
       * '/dealerships' - Dealership management page (Team member 3)
       */
      routes: {
        // Main landing page - shows navigation to all modules
        '/': (context) => HomePage(),

        // Sales management module - your complete implementation
        '/sales': (context) => SalesPage(),

        // TODO: Team members will add their routes here
        // '/customers': (context) => CustomerPage(),
        // '/cars': (context) => CarPage(),
        // '/dealerships': (context) => DealershipPage(),
      },

      /**
       * Handle unknown routes gracefully
       * Returns user to home page if they navigate to non-existent route
       */
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      },
    );
  }
}