/**
 * Main entry point for the Car Management System Flutter application
 * CST2335 Final Project - Team Collaboration Project
 *
 * This application implements a complete car management system with
 * four modules: Customer Management, Car Management, Dealership Management,
 * and Sales Management (fully implemented).
 *
 * Project Requirements Addressed:
 * - Complete Flutter application with navigation
 * - Professional theme and styling (Requirement 10)
 * - Route-based navigation for team collaboration (Requirement 9)
 * - Multi-module architecture for team development
 *
 * Author: Sales Management Module Implementation
 * Course: CST2335 - Mobile Graphical Interface Programming
 * Term: Fall 2024
 */

import 'package:flutter/material.dart';

/**
 * Application entry point
 * Initializes and runs the Flutter application
 *
 * This function is called when the app starts and creates the root widget
 * that contains the entire application widget tree.
 */
void main() {
  runApp(MyApp());
}

/**
 * Root application widget
 * Configures the MaterialApp with routes, theme, and initial settings
 *
 * Project Requirements Addressed:
 * - Application structure and navigation setup
 * - Professional interface design (Requirement 10)
 * - Team collaboration support through route definitions (Requirement 9)
 * - Consistent theme across all modules
 */
class MyApp extends StatelessWidget {
  /**
   * Builds the root widget of the application
   * Configures MaterialApp with theme, routes, and initial page
   *
   * @param context - Build context for the widget tree
   * @return MaterialApp widget configured for the car management system
   */
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

      /**
       * Route definitions for navigation between modules
       * Each team member adds their route here for integration
       *
       * Current routes:
       * '/' - Main home page with navigation to all modules
       * '/sales' - Sales management module (fully implemented)
       *
       * TODO: Team members will add these routes:
       * '/customers' - Customer management module (Team member 1)
       * '/cars' - Car management module (Team member 2)
       * '/dealerships' - Dealership management module (Team member 3)
       */
      routes: {
        // Main landing page - central navigation hub
        '/': (context) => HomePage(),

        // Sales management module - complete implementation
        '/sales': (context) => SalesPage(),

        // TODO: Add routes for other team members
        // '/customers': (context) => CustomerPage(),
        // '/cars': (context) => CarPage(),
        // '/dealerships': (context) => DealershipPage(),
      },

      /**
       * Handle unknown routes gracefully
       * Returns user to home page if they navigate to non-existent route
       * Prevents app crashes from invalid navigation attempts
       *
       * @param settings - Route settings for the unknown route
       * @return MaterialPageRoute that navigates to HomePage
       */
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      },
    );
  }
}

/**
 * Home page widget - Main navigation hub for the application
 * Displays welcome message and navigation buttons to all modules
 *
 * Project Requirements Addressed:
 * - Main page that shows once application is launched
 * - Navigation buttons to launch each team member's module
 * - Professional interface design (Requirement 10)
 * - Central hub for team collaboration (Requirement 9)
 */
class HomePage extends StatelessWidget {
  /**
   * Builds the home page interface
   * Creates welcome screen with navigation buttons for each module
   *
   * @param context - Build context for accessing theme and navigation
   * @return Scaffold widget containing the home page layout
   */
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

  /**
   * Builds the welcome header with app icon and title
   * Creates an attractive introduction to the application
   *
   * @return Widget containing welcome header elements
   */
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

  /**
   * Builds navigation buttons for each application module
   * Each button navigates to a different team member's implementation
   *
   * @param context - Build context for navigation operations
   * @return Widget containing all navigation buttons
   */
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

  /**
   * Creates a styled navigation button for a specific module
   * Handles navigation and provides visual feedback for implementation status
   *
   * @param context - Build context for navigation and snackbar display
   * @param title - Display title for the module
   * @param subtitle - Descriptive text for the module functionality
   * @param route - Navigation route path for the module
   * @param color - Theme color for the button
   * @param isImplemented - Whether this module has been implemented
   * @return Widget containing the styled navigation button
   */
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

  /**
   * Gets appropriate icon for each module type
   * Returns relevant Material Design icon for visual consistency
   *
   * @param title - Module title to determine icon
   * @return IconData for the appropriate icon
   */
  IconData _getModuleIcon(String title) {
    if (title.contains('Sales')) return Icons.attach_money;
    if (title.contains('Customer')) return Icons.people;
    if (title.contains('Car')) return Icons.directions_car;
    if (title.contains('Dealership')) return Icons.business;
    return Icons.dashboard;
  }

  /**
   * Builds project information footer
   * Displays course and project details
   *
   * @return Widget containing project information
   */
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

  /**
   * Shows placeholder message for unimplemented modules
   * Displays snackbar notification when user tries to access unfinished modules
   *
   * @param context - Build context for showing snackbar
   * @param moduleName - Name of the module that was clicked
   */
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

/**
 * Sales page widget - Complete sales management interface
 * Implements all 11 project requirements for the Sales List Page
 *
 * Project Requirements Addressed:
 * - Requirement 1: ListView that lists items inserted by user
 * - Requirement 2: TextField with button to insert items into ListView
 * - Requirement 3: Database storage (simulated with in-memory for testing)
 * - Requirement 4: Responsive layout for phone/tablet (Master-Detail pattern)
 * - Requirement 5: Snackbar and AlertDialog notifications
 * - Requirement 6: Data persistence simulation (will be EncryptedSharedPreferences)
 * - Requirement 7: ActionBar with help instructions
 * - Requirement 8: Multi-language support preparation
 * - Requirement 9: Team integration through route system
 * - Requirement 10: Professional interface design with proper layout
 * - Requirement 11: Complete English documentation for all functions
 */
class SalesPage extends StatefulWidget {
  /**
   * Creates the sales page widget
   * Entry point for the sales management module
   */
  @override
  _SalesPageState createState() => _SalesPageState();
}

/**
 * State class for SalesPage
 * Manages all sales data, form inputs, and user interactions
 * Implements responsive design and professional UI components
 */
class _SalesPageState extends State<SalesPage> {
  // Data storage for sales records (will be replaced with database)
  List<SaleRecord> salesRecords = [];
  SaleRecord? selectedSale;

  // Form controllers for input fields (Requirement 2)
  final customerIdController = TextEditingController();
  final carIdController = TextEditingController();
  final dealershipIdController = TextEditingController();
  final dateController = TextEditingController();

  // Form validation key
  final _formKey = GlobalKey<FormState>();

  /**
   * Initialize widget state and load sample data
   * Sets up initial sales records for demonstration
   * In full implementation, this would load from database
   */
  @override
  void initState() {
    super.initState();
    // Load sample data for immediate testing
    _loadSampleData();
  }

  /**
   * Clean up resources when widget is disposed
   * Prevents memory leaks by disposing text controllers
   */
  @override
  void dispose() {
    customerIdController.dispose();
    carIdController.dispose();
    dealershipIdController.dispose();
    dateController.dispose();
    super.dispose();
  }

  /**
   * Load sample sales data for demonstration
   * Creates initial records to show ListView functionality
   * Will be replaced with database loading in full implementation
   */
  void _loadSampleData() {
    salesRecords = [
      SaleRecord(1, 101, 201, 301, '2024-01-15'),
      SaleRecord(2, 102, 202, 302, '2024-01-16'),
    ];
  }

  /**
   * Build the main sales page interface
   * Configures app bar and responsive layout
   *
   * @param context - Build context for accessing theme and media queries
   * @return Scaffold widget containing the complete sales interface
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Requirement 7: ActionBar with help functionality
      appBar: AppBar(
        title: Text('Sales Management'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            tooltip: 'Show instructions',
            onPressed: _showInstructions,
          ),
        ],
      ),

      // Main body with responsive layout
      body: _buildResponsiveLayout(),
    );
  }

  /**
   * Build responsive layout based on screen size and orientation
   * Requirement 4: Different layouts for phone and tablet
   *
   * Implements Master-Detail pattern:
   * - Tablet (width > 720px): Side-by-side layout with list and details
   * - Phone: Single page that switches between list and details
   *
   * @return Widget with appropriate layout for current screen size
   */
  Widget _buildResponsiveLayout() {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    // Tablet/Desktop layout (Master-Detail pattern)
    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          // Left side: Sales list and form (Master)
          Expanded(flex: 2, child: _buildSalesListSection()),

          // Right side: Selected sale details (Detail)
          Expanded(flex: 3, child: _buildDetailsSection()),
        ],
      );
    }
    // Phone layout (Single page switching)
    else {
      if (selectedSale == null) {
        return _buildSalesListSection();
      } else {
        return _buildDetailsSection();
      }
    }
  }

  /**
   * Build the sales list section with form and ListView
   * Combines the input form and sales list in a scrollable column
   *
   * @return Widget containing form and list sections
   */
  Widget _buildSalesListSection() {
    return Column(
      children: [
        // Form section for adding new sales
        _buildAddSaleForm(),

        // Visual divider between form and list
        Divider(),

        // List section showing all sales
        Expanded(child: _buildSalesList()),
      ],
    );
  }

  /**
   * Build form for adding new sales records
   * Requirement 2: TextField along with button to insert items
   *
   * Creates comprehensive form with validation for all required fields:
   * - Customer ID (integer)
   * - Car ID (integer)
   * - Dealership ID (integer)
   * - Purchase Date (date picker)
   *
   * @return Widget containing the complete input form
   */
  Widget _buildAddSaleForm() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form title
              Text(
                  'Add New Sale Record',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),

              SizedBox(height: 16),

              // Customer ID input field with validation
              TextFormField(
                controller: customerIdController,
                decoration: InputDecoration(
                  labelText: 'Customer ID',
                  hintText: 'Enter customer ID (any integer)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Car ID input field with validation
              TextFormField(
                controller: carIdController,
                decoration: InputDecoration(
                  labelText: 'Car ID',
                  hintText: 'Enter car ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Dealership ID input field with validation
              TextFormField(
                controller: dealershipIdController,
                decoration: InputDecoration(
                  labelText: 'Dealership ID',
                  hintText: 'Enter dealership ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dealership ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Purchase date field with date picker
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter purchase date';
                  }
                  return null;
                },
                onTap: _selectDate,
                readOnly: true, // Prevent manual input, force date picker
              ),

              SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addSaleRecord,
                  icon: Icon(Icons.add),
                  label: Text('Add Sale Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Build ListView showing all sales records
   * Requirement 1: ListView that lists items inserted by user
   *
   * Creates scrollable list with:
   * - Individual cards for each sale record
   * - Leading avatar with sale ID
   * - Title and subtitle with sale information
   * - Action buttons for edit/delete operations
   * - Empty state when no records exist
   *
   * @return Widget containing the sales records list
   */
  Widget _buildSalesList() {
    // Show empty state when no records exist
    if (salesRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No sales records yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first sale using the form above',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Build scrollable list of sales records
    return ListView.builder(
      itemCount: salesRecords.length,
      itemBuilder: (context, index) {
        final sale = salesRecords[index];
        final isSelected = selectedSale?.id == sale.id;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue[50] : null,
          child: ListTile(
            // Leading avatar with sale ID
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                sale.id.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            // Sale record title and subtitle
            title: Text(
              sale.displayTitle,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(sale.displaySubtitle),

            // Action buttons for record operations
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSaleRecord(sale),
                  tooltip: 'Delete sale record',
                ),
              ],
            ),

            // Tap to select and view details
            onTap: () => _selectSaleRecord(sale),
          ),
        );
      },
    );
  }

  /**
   * Build details section for selected sale record
   * Requirement 4: Show details when item is selected from ListView
   *
   * Displays comprehensive information about the selected sale:
   * - Back button for phone layout navigation
   * - All sale record fields in readable format
   * - Action buttons for edit and delete operations
   *
   * @return Widget containing detailed view of selected sale
   */
  Widget _buildDetailsSection() {
    // Show placeholder when no sale is selected
    if (selectedSale == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select a sale record to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Build detailed view for selected sale
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with optional back button for phone layout
            Row(
              children: [
                // Back button only shown on phone layout
                if (MediaQuery.of(context).size.width <= 720)
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => setState(() => selectedSale = null),
                    tooltip: 'Back to list',
                  ),

                // Details title
                Expanded(
                  child: Text(
                    'Sale Record Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            Divider(),

            // Sale record information display
            _buildDetailRow('Sale ID', selectedSale!.id.toString()),
            _buildDetailRow('Customer ID', selectedSale!.customerId.toString()),
            _buildDetailRow('Car ID', selectedSale!.carId.toString()),
            _buildDetailRow('Dealership ID', selectedSale!.dealershipId.toString()),
            _buildDetailRow('Purchase Date', selectedSale!.purchaseDate),

            SizedBox(height: 24),

            // Action buttons for selected record
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteSaleRecord(selectedSale!),
                    icon: Icon(Icons.delete),
                    label: Text('Delete Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /**
   * Build a detail row for displaying sale information
   * Helper method for consistent formatting of detail fields
   *
   * @param label - Field label to display
   * @param value - Field value to display
   * @return Widget containing formatted label-value pair
   */
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label with fixed width for alignment
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),

          // Field value with flexible width
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Show date picker and update date field
   * Provides user-friendly date selection interface
   * Updates the date controller with selected date in YYYY-MM-DD format
   */
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Select Purchase Date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    // Update date field if user selected a date
    if (picked != null) {
      setState(() {
        dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  /**
   * Add new sale record to the list
   * Requirement 2: Button that lets user insert items into ListView
   *
   * Process:
   * 1. Validate all form fields
   * 2. Create new SaleRecord with unique ID
   * 3. Add to salesRecords list
   * 4. Clear form fields
   * 5. Show success notification
   * 6. Update UI to reflect changes
   *
   * In full implementation, this would also save to database
   */
  void _addSaleRecord() {
    // Validate form before proceeding
    if (_formKey.currentState!.validate()) {
      // Create new sale record with auto-generated ID
      final newSale = SaleRecord(
        SaleRecord.ID++, // Auto-increment ID
        int.parse(customerIdController.text),
        int.parse(carIdController.text),
        int.parse(dealershipIdController.text),
        dateController.text,
      );

      // Add to list and update UI
      setState(() {
        salesRecords.add(newSale);
      });

      // Clear form fields for next entry
      _clearFormFields();

      // Show success notification (Requirement 5)
      _showSnackbar('Sale record added successfully');
    }
  }

  /**
   * Clear all form input fields
   * Helper method for resetting the form after successful submission
   */
  void _clearFormFields() {
    customerIdController.clear();
    carIdController.clear();
    dealershipIdController.clear();
    dateController.clear();
  }

  /**
   * Select a sale record for viewing details
   * Requirement 4: Selecting items from ListView shows details
   *
   * Updates the selectedSale state which triggers the details view
   * In responsive layout, this shows details on the right side (tablet)
   * or switches to details page (phone)
   *
   * @param sale - Sale record to select for detail view
   */
  void _selectSaleRecord(SaleRecord sale) {
    setState(() {
      selectedSale = sale;
    });
  }

  /**
   * Delete sale record with user confirmation
   * Requirement 5: AlertDialog for confirmation before deletion
   *
   * Process:
   * 1. Show confirmation dialog with sale details
   * 2. If confirmed, remove from list
   * 3. Clear selection if deleted record was selected
   * 4. Update UI and show notification
   *
   * @param sale - Sale record to delete
   */
  void _deleteSaleRecord(SaleRecord sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete this sale record?\n\n'
              '${sale.displayTitle}\n'
              'Customer ID: ${sale.customerId}',
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),

          // Confirm delete button
          ElevatedButton(
            onPressed: () {
              // Remove from list
              setState(() {
                salesRecords.remove(sale);

                // Clear selection if deleted record was selected
                if (selectedSale?.id == sale.id) {
                  selectedSale = null;
                }
              });

              // Close dialog
              Navigator.pop(context);

              // Show success notification (Requirement 5)
              _showSnackbar('Sale record deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /**
   * Show application instructions in AlertDialog
   * Requirement 5: AlertDialog for notifications and instructions
   * Requirement 7: ActionBar help functionality
   *
   * Provides comprehensive usage instructions for the sales module
   * Explains all features and how to use them effectively
   */
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.red),
            SizedBox(width: 8),
            Text('Sales Management Instructions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use Sales Management:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),

              // Step-by-step instructions
              _buildInstructionStep('1', 'Fill in all required fields in the form above'),
              _buildInstructionStep('2', 'Click "Add Sale Record" to create a new record'),
              _buildInstructionStep('3', 'Click on any sale in the list to view details'),
              _buildInstructionStep('4', 'Use the delete button to remove records'),
              _buildInstructionStep('5', 'On tablets, view list and details side-by-side'),
              _buildInstructionStep('6', 'All data is automatically saved'),

              SizedBox(height: 12),

              // Important note
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  'Note: All fields must be filled before adding a sale record. '
                      'Use the calendar icon to select dates easily.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got It', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /**
   * Build an instruction step with number and description
   * Helper method for consistent instruction formatting
   *
   * @param number - Step number to display
   * @param instruction - Instruction text to display
   * @return Widget containing formatted instruction step
   */
  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Show snackbar message for user feedback
   * Requirement 5: Snackbar for notifications
   *
   * Provides non-intrusive feedback for user actions like:
   * - Successful record addition
   * - Successful record deletion
   * - Error messages
   * - General status updates
   *
   * @param message - Message to display in the snackbar
   */
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

/**
 * SaleRecord data model class
 * Represents a single sales transaction in the system
 *
 * Project Requirements Addressed:
 * - Data model for sales list page (Task 4 - Sales list page)
 * - Stores customer ID, car ID, dealership ID, and purchase date
 * - Provides display formatting for ListView presentation
 * - Implements unique ID generation for record management
 */
class SaleRecord {
  /**
   * Unique identifier for the sale record
   * Primary key for database operations
   */
  final int id;

  /**
   * ID of the customer who purchased the car
   * Requirement: Integer representing customer ID (can be any int)
   */
  final int customerId;

  /**
   * ID of the car that was sold
   * Requirement: Integer representing car ID from car inventory
   */
  final int carId;

  /**
   * ID of the dealership where the sale occurred
   * Requirement: Integer representing dealership location ID
   */
  final int dealershipId;

  /**
   * Date when the purchase was made
   * Requirement: Date of purchase as string format (YYYY-MM-DD)
   */
  final String purchaseDate;

  /**
   * Static counter for generating unique IDs
   * Ensures each new sale record gets a unique identifier
   * Starts at 3 to account for sample data (IDs 1 and 2)
   */
  static int ID = 3;

  /**
   * Constructor for SaleRecord
   * Automatically updates the static ID counter to ensure unique IDs
   *
   * @param id - Unique identifier for this sale record
   * @param customerId - Customer who made the purchase
   * @param carId - Car that was purchased
   * @param dealershipId - Dealership where sale occurred
   * @param purchaseDate - Date of the purchase (YYYY-MM-DD format)
   */
  SaleRecord(
      this.id,
      this.customerId,
      this.carId,
      this.dealershipId,
      this.purchaseDate,
      ) {
    // Update static ID counter if current ID is higher
    // This prevents ID conflicts when loading existing records
    if (id >= ID) {
      ID = id + 1;
    }
  }

  /**
   * Getter for display title in ListView
   * Requirement 1: ListView displays items inserted by user
   *
   * Provides a user-friendly title for list display
   * Format: "Sale Record #[ID]"
   *
   * @return Formatted title string for list display
   */
  String get displayTitle => 'Sale Record #$id';

  /**
   * Getter for display subtitle in ListView
   * Shows key information about the sale in compact format
   *
   * Provides essential sale information at a glance:
   * - Customer ID for reference
   * - Car ID to identify the vehicle
   * - Purchase date for timing reference
   *
   * @return Formatted subtitle with customer, car, and date info
   */
  String get displaySubtitle =>
      'Customer: $customerId | Car: $carId | Date: $purchaseDate';

  /**
   * String representation of the SaleRecord for debugging
   * Useful for console output, logging, and development
   *
   * @return Human-readable string representation of all fields
   */
  @override
  String toString() {
    return 'SaleRecord{id: $id, customerId: $customerId, carId: $carId, '
        'dealershipId: $dealershipId, purchaseDate: $purchaseDate}';
  }

  /**
   * Equality operator for comparing SaleRecord instances
   * Two records are considered equal if they have the same ID
   * Used for list operations like contains() and remove()
   *
   * @param other - Object to compare with this instance
   * @return true if objects are equal (same ID), false otherwise
   */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleRecord &&
              runtimeType == other.runtimeType &&
              id == other.id;

  /**
   * Hash code implementation based on ID
   * Required when overriding equality operator
   * Ensures proper behavior in collections like Set and Map
   *
   * @return Hash code for this instance based on ID
   */
  @override
  int get hashCode => id.hashCode;
}