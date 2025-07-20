import 'package:flutter/material.dart';

/**
 * HomePage widget - Main landing page for the Car Management System
 * This page serves as the central navigation hub for all application modules
 *
 * Project Requirements Addressed:
 * - Main page that shows once application is launched
 * - 4 buttons that launch pages for each team member's project part
 * - Requirement 7: ActionBar with ActionItems that displays help dialog
 * - Requirement 5: AlertDialog for notifications and instructions
 * - Requirement 10: Professional interface design with proper layout
 */
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Requirement 7: ActionBar with ActionItems for help functionality
      appBar: AppBar(
        title: Text('Car Management System'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          // Help button that displays instructions dialog
          IconButton(
            icon: Icon(Icons.help),
            tooltip: 'Show application instructions',
            onPressed: () => _showInstructions(context),
          ),
        ],
      ),

      // FIXED: Make body scrollable to see all content
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
            _buildNavigationSection(context),

            // Extra space at bottom to ensure content is visible
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /**
   * Builds the welcome header section with app title and description
   * Provides clear indication of app purpose and functionality
   */
  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        // App icon or logo placeholder
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

        // Subtitle description
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

  /**
   * Builds the navigation section with buttons for each team member's module
   * Each button navigates to a different part of the application
   *
   * @param context - Build context for navigation
   */
  Widget _buildNavigationSection(BuildContext context) {
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

        // Navigation buttons for each module
        _buildNavigationButton(
          context,
          title: 'Customer Management',
          subtitle: 'Manage customer information and records',
          route: '/customers',
          icon: Icons.people,
          color: Colors.green,
          isImplemented: false, // Team member 1 will implement
        ),

        SizedBox(height: 16),

        _buildNavigationButton(
          context,
          title: 'Car Management',
          subtitle: 'Manage car inventory and specifications',
          route: '/cars',
          icon: Icons.directions_car,
          color: Colors.orange,
          isImplemented: false, // Team member 2 will implement
        ),

        SizedBox(height: 16),

        _buildNavigationButton(
          context,
          title: 'Dealership Management',
          subtitle: 'Manage dealership locations and information',
          route: '/dealerships',
          icon: Icons.business,
          color: Colors.purple,
          isImplemented: false, // Team member 3 will implement
        ),

        SizedBox(height: 16),

        // *** SALES MANAGEMENT BUTTON - YOUR IMPLEMENTATION ***
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildNavigationButton(
            context,
            title: '🚀 Sales Management',
            subtitle: '✅ Manage sales records and transactions - READY!',
            route: '/sales',
            icon: Icons.attach_money,
            color: Colors.red,
            isImplemented: true, // Your implementation
          ),
        ),
      ],
    );
  }

  /**
   * Creates a styled navigation button for each module
   * Handles navigation and shows appropriate feedback for unimplemented modules
   *
   * @param context - Build context for navigation and snackbar
   * @param title - Button display title
   * @param subtitle - Descriptive text for the module
   * @param route - Navigation route path
   * @param icon - Icon to display on button
   * @param color - Theme color for the button
   * @param isImplemented - Whether this module has been implemented
   */
  Widget _buildNavigationButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String route,
        required IconData icon,
        required Color color,
        required bool isImplemented,
      }) {
    return Card(
      elevation: isImplemented ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print('🔥 Clicked on $title - isImplemented: $isImplemented');

          if (isImplemented) {
            // Navigate to the implemented module
            print('🚀 Navigating to $route');
            try {
              Navigator.pushNamed(context, route);
            } catch (e) {
              print('❌ Navigation error: $e');
              _showSnackbar(context, 'Navigation error: $e');
            }
          } else {
            // Show placeholder message for unimplemented modules
            // Requirement 5: Use Snackbar for notifications
            _showModuleNotImplemented(context, title);
          }
        },
        child: Container(
          decoration: isImplemented ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
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
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: isImplemented ? Border.all(color: color, width: 2) : null,
                  ),
                  child: Icon(
                    icon,
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

                      // Implementation status indicator
                      if (!isImplemented) ...[
                        SizedBox(height: 4),
                        Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'READY TO USE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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

  /**
   * Shows application instructions in an AlertDialog
   * Requirement 5: AlertDialog for notifications
   * Requirement 7: ActionBar help functionality
   *
   * @param context - Build context for showing dialog
   */
  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // Dialog title
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.blue),
            SizedBox(width: 8),
            Text('Application Instructions'),
          ],
        ),

        // Dialog content with instructions
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use the Car Management System:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 12),

            Text('1. Select a management module from the buttons below'),
            Text('2. Add, view, update, or delete records in each module'),
            Text('3. All data is automatically saved to the database'),
            Text('4. Use the help button in each module for specific instructions'),
            Text('5. The interface adapts to phone and tablet layouts'),

            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🚀 Sales Management is ready to use!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // Dialog actions
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got It'),
          ),
        ],
      ),
    );
  }

  /**
   * Shows a Snackbar message for modules not yet implemented
   * Requirement 5: Use Snackbar for notifications
   *
   * @param context - Build context for showing snackbar
   * @param moduleName - Name of the module that was clicked
   */
  void _showModuleNotImplemented(BuildContext context, String moduleName) {
    _showSnackbar(context, '$moduleName will be implemented by team members');
  }

  /**
   * Show snackbar with custom message
   */
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message),
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