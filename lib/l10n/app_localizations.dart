// lib/l10n/app_localizations.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppLocalizations class for handling multi-language support
/// Requirement 8: Support for at least 1 other language (American vs British English)
///
/// Implementation follows Flutter internationalization best practices
/// as specified in the course requirements using JSON translation files
class AppLocalizations {
  /// Constructor that initializes the locale and empty strings map
  AppLocalizations(this.locale) {
    _localizedStrings = <String, String>{};
  }

  /// Static method to get AppLocalizations from context
  /// Standard pattern for accessing localized strings throughout the app
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Localization delegate for Flutter's internationalization system
  /// This is required by MaterialApp's localizationsDelegates
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  /// Current locale for this AppLocalizations instance
  final Locale locale;

  /// Map storing all localized strings loaded from JSON files
  late Map<String, String> _localizedStrings;

  /// Load translation strings from JSON file based on current locale
  /// This method is called automatically by the LocalizationsDelegate
  Future<void> load() async {
    // Load JSON file based on locale (e.g., 'en.json' or 'en_GB.json')
    String jsonFileName = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}.json'
        : '${locale.languageCode}.json';

    try {
      // Load the JSON file from assets/translations/
      String jsonString = await rootBundle.loadString('assets/translations/$jsonFileName');

      // Parse JSON and convert to string map
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      print('✅ Loaded translations from: $jsonFileName');
      print('✅ Loaded ${_localizedStrings.length} translation keys');

    } catch (e) {
      print('❌ Error loading translation file $jsonFileName: $e');

      // Fallback: try loading basic language file if country-specific fails
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        try {
          String fallbackFileName = '${locale.languageCode}.json';
          String jsonString = await rootBundle.loadString('assets/translations/$fallbackFileName');
          Map<String, dynamic> jsonMap = json.decode(jsonString);

          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });

          print('✅ Loaded fallback translations from: $fallbackFileName');

        } catch (fallbackError) {
          print('❌ Error loading fallback translation file: $fallbackError');

          // Ultimate fallback: provide English defaults
          _localizedStrings = {
            'app_title': 'Car Management System',
            'sales_management': 'Sales Management',
            'color': 'Color',
            'center': 'Center',
            'favorite': 'Favorite',
            'organize': 'Organize',
            'license': 'License',
          };
        }
      }
    }
  }

  /// Translate a key to localized string
  /// Returns the translated string or the key itself if not found
  ///
  /// [key] - The translation key to look up
  /// Returns: Translated string or null if key not found
  String? translate(String key) {
    final translation = _localizedStrings[key];
    if (translation == null) {
      print('⚠️ Translation key not found: $key');
    }
    return translation;
  }

  /// Get translated string with fallback to key if not found
  /// This is a convenience method that never returns null
  ///
  /// [key] - The translation key to look up
  /// Returns: Translated string or the key itself as fallback
  String getTranslatedValue(String key) {
    return translate(key) ?? key;
  }

  /// Helper method for getting translated text with null safety
  /// Provides a default value if translation is not found
  ///
  /// [key] - The translation key to look up
  /// [defaultValue] - Default value to use if key not found
  /// Returns: Translated string or default value
  String getTranslation(String key, String defaultValue) {
    return translate(key) ?? defaultValue;
  }

  /// Delete record - method name matching course materials
  /// Provides backwards compatibility with existing code patterns
  String? deleteRecord(String key) {
    return translate(key);
  }

  // === CONVENIENCE GETTERS FOR COMMON STRINGS ===
  // These match the JSON keys we created

  /// Application title
  String get appTitle => getTranslatedValue('app_title');

  /// Sales management title
  String get salesManagement => getTranslatedValue('sales_management');

  /// Add new record form title
  String get addNewRecord => getTranslatedValue('add_new_record');

  /// Customer ID label
  String get customerID => getTranslatedValue('customer_id');

  /// Car ID label
  String get carID => getTranslatedValue('car_id');

  /// Dealership ID label
  String get dealershipID => getTranslatedValue('dealership_id');

  /// Purchase date label
  String get purchaseDate => getTranslatedValue('purchase_date');

  /// Add record button
  String get addRecord => getTranslatedValue('add_record');

  /// Delete record button
  String get deleteRecordButton => getTranslatedValue('delete_record');

  /// Validation error title
  String get validationError => getTranslatedValue('validation_error');

  /// Invalid customer ID message
  String get invalidCustomerID => getTranslatedValue('invalid_customer_id');

  /// Invalid car ID message
  String get invalidCarID => getTranslatedValue('invalid_car_id');

  /// Invalid dealership ID message
  String get invalidDealershipID => getTranslatedValue('invalid_dealership_id');

  /// Record added success message
  String get recordAdded => getTranslatedValue('record_added');

  /// Record deleted success message
  String get recordDeleted => getTranslatedValue('record_deleted');

  /// No records message
  String get noRecords => getTranslatedValue('no_records');

  /// Select record instruction
  String get selectRecord => getTranslatedValue('select_record');

  // === LANGUAGE DIFFERENCE DEMONSTRATION ===
  // These demonstrate American vs British English differences

  /// Color/Colour - primary example of spelling difference
  String get color => getTranslatedValue('color');

  /// Center/Centre - another common difference
  String get center => getTranslatedValue('center');

  /// Favorite/Favourite - demonstrates -ite vs -ite endings
  String get favorite => getTranslatedValue('favorite');

  /// Organize/Organise - demonstrates -ize vs -ise endings
  String get organize => getTranslatedValue('organize');

  /// License/Licence - demonstrates noun vs verb differences
  String get license => getTranslatedValue('license');

  /// Get current language variant name for display
  String get languageVariant {
    return locale.countryCode == 'GB' ? 'British English' : 'American English';
  }

  /// Check if current locale is British English
  bool get isBritish => locale.countryCode == 'GB';

  /// Check if current locale is American English
  bool get isAmerican => locale.countryCode == 'US';

  /// Get all available translation keys (for debugging)
  List<String> get availableKeys => _localizedStrings.keys.toList();

  /// Get translation count (for debugging)
  int get translationCount => _localizedStrings.length;
}

/// LocalizationsDelegate implementation for AppLocalizations
/// This class is required by Flutter's localization system
/// It handles loading and caching of AppLocalizations instances
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// Constructor - marked as const for performance
  const _AppLocalizationsDelegate();

  /// Check if the given locale is supported by this delegate
  /// Currently supports English variants (en_US, en_GB, en)
  @override
  bool isSupported(Locale locale) {
    // Support English language with US and GB variants
    return locale.languageCode == 'en';
  }

  /// Load and initialize AppLocalizations for the given locale
  /// This method is called by Flutter when the locale changes
  @override
  Future<AppLocalizations> load(Locale locale) async {
    print('🌐 Loading AppLocalizations for locale: ${locale.toString()}');

    // Create AppLocalizations instance
    AppLocalizations localizations = AppLocalizations(locale);

    // Load translations from JSON file
    await localizations.load();

    print('✅ AppLocalizations loaded successfully');
    return localizations;
  }

  /// Determine whether the delegate should reload
  /// Returns false since our translations don't change during runtime
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}