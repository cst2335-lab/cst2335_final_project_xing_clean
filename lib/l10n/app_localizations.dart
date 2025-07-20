// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

/**
 * Application localization class for multi-language support
 * Requirement 8: Support for at least 1 other language
 *
 * Implements American English vs British English differences:
 * - color vs colour
 * - organization vs organisation
 * - center vs centre
 * - customize vs customise
 */
class AppLocalizations {
  /**
   * Get localization instance from context
   *
   * @param context - Build context to extract locale from
   * @return AppLocalizations instance or null if not found
   */
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /**
   * Delegate for Flutter's localization system
   * Handles loading and creation of localization instances
   */
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  /**
   * List of supported locales for this application
   * Supports both American and British English variants
   */
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),  // American English
    Locale('en', 'GB'),  // British English
  ];

  /**
   * Current locale for this localization instance
   */
  final Locale locale;

  /**
   * Constructor for AppLocalizations
   *
   * @param locale - Locale to use for this instance
   */
  AppLocalizations(this.locale);

  /**
   * Localized text for "Sales Management"
   * Same in both American and British English
   */
  String get salesManagement {
    switch (locale.countryCode) {
      case 'GB':
        return 'Sales Management';
      case 'US':
      default:
        return 'Sales Management';
    }
  }

  /**
   * Localized text for "Customer ID"
   * Same in both variants
   */
  String get customerID {
    switch (locale.countryCode) {
      case 'GB':
        return 'Customer ID';
      case 'US':
      default:
        return 'Customer ID';
    }
  }

  /**
   * Localized text for color/colour
   * Demonstrates British vs American spelling difference
   */
  String get colour {
    switch (locale.countryCode) {
      case 'GB':
        return 'Colour';
      case 'US':
      default:
        return 'Color';
    }
  }

  /**
   * Localized text for organization/organisation
   * Another British vs American spelling difference
   */
  String get organisation {
    switch (locale.countryCode) {
      case 'GB':
        return 'Organisation';
      case 'US':
      default:
        return 'Organization';
    }
  }

  /**
   * Localized text for "Add Sale Record"
   * Slight variation between variants
   */
  String get addSaleRecord {
    switch (locale.countryCode) {
      case 'GB':
        return 'Add Sale Record';
      case 'US':
      default:
        return 'Add Sales Record';
    }
  }

  /**
   * Localized text for center/centre
   * British vs American spelling difference
   */
  String get centre {
    switch (locale.countryCode) {
      case 'GB':
        return 'Centre';
      case 'US':
      default:
        return 'Center';
    }
  }

  /**
   * Localized text for customize/customise
   * British vs American spelling difference
   */
  String get customise {
    switch (locale.countryCode) {
      case 'GB':
        return 'Customise';
      case 'US':
      default:
        return 'Customize';
    }
  }
}

/**
 * Localization delegate implementation
 * Handles the loading and creation of AppLocalizations instances
 */
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /**
   * Check if the given locale is supported
   *
   * @param locale - Locale to check support for
   * @return true if locale is supported, false otherwise
   */
  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  /**
   * Load localization for the given locale
   *
   * @param locale - Locale to load localization for
   * @return Future containing AppLocalizations instance
   */
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  /**
   * Determine if delegate should reload
   *
   * @param old - Previous delegate instance
   * @return false as we don't need to reload
   */
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}