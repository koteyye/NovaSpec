import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NovaSpec'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @fileExplorer.
  ///
  /// In en, this message translates to:
  /// **'File Explorer'**
  String get fileExplorer;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @openProject.
  ///
  /// In en, this message translates to:
  /// **'Open Project'**
  String get openProject;

  /// No description provided for @recentProjects.
  ///
  /// In en, this message translates to:
  /// **'Recent Projects'**
  String get recentProjects;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Project Description'**
  String get projectDescription;

  /// No description provided for @projectManagement.
  ///
  /// In en, this message translates to:
  /// **'Project Management'**
  String get projectManagement;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @createFile.
  ///
  /// In en, this message translates to:
  /// **'Create File'**
  String get createFile;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToRussian.
  ///
  /// In en, this message translates to:
  /// **'Switch to Russian'**
  String get switchToRussian;

  /// No description provided for @svgIconsTest.
  ///
  /// In en, this message translates to:
  /// **'SVG Icons Test'**
  String get svgIconsTest;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreen;

  /// No description provided for @workspaceScreen.
  ///
  /// In en, this message translates to:
  /// **'Workspace Screen'**
  String get workspaceScreen;

  /// No description provided for @projectManagementScreen.
  ///
  /// In en, this message translates to:
  /// **'Project Management Screen'**
  String get projectManagementScreen;

  /// No description provided for @settingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Settings Screen'**
  String get settingsScreen;

  /// No description provided for @aiAssistantScreen.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant Screen'**
  String get aiAssistantScreen;

  /// No description provided for @fileExplorerScreen.
  ///
  /// In en, this message translates to:
  /// **'File Explorer Screen'**
  String get fileExplorerScreen;

  /// No description provided for @templatesScreen.
  ///
  /// In en, this message translates to:
  /// **'Templates Screen'**
  String get templatesScreen;

  /// No description provided for @specPreview.
  ///
  /// In en, this message translates to:
  /// **'Spec Preview'**
  String get specPreview;

  /// No description provided for @specContent.
  ///
  /// In en, this message translates to:
  /// **'Spec Content'**
  String get specContent;

  /// No description provided for @textEditor.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get textEditor;

  /// No description provided for @initialContent.
  ///
  /// In en, this message translates to:
  /// **'Initial Content'**
  String get initialContent;

  /// No description provided for @swaggerUrl.
  ///
  /// In en, this message translates to:
  /// **'Swagger URL'**
  String get swaggerUrl;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NovaSpec - Phase 2 Complete'**
  String get appTitle;

  /// No description provided for @languageTest.
  ///
  /// In en, this message translates to:
  /// **'Language Test (en)'**
  String get languageTest;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @autoSaveDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically save changes'**
  String get autoSaveDescription;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Show app notifications'**
  String get notificationsDescription;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to default values?'**
  String get resetSettingsConfirm;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get errorSavingSettings;

  /// No description provided for @errorResettingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error resetting settings'**
  String get errorResettingSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsReset;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @componentDemo.
  ///
  /// In en, this message translates to:
  /// **'Component Demo'**
  String get componentDemo;

  /// No description provided for @buttons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get buttons;

  /// No description provided for @textFields.
  ///
  /// In en, this message translates to:
  /// **'Text Fields'**
  String get textFields;

  /// No description provided for @dialogs.
  ///
  /// In en, this message translates to:
  /// **'Dialogs'**
  String get dialogs;

  /// No description provided for @toastNotifications.
  ///
  /// In en, this message translates to:
  /// **'Toast Notifications'**
  String get toastNotifications;

  /// No description provided for @otherComponents.
  ///
  /// In en, this message translates to:
  /// **'Other Components'**
  String get otherComponents;

  /// No description provided for @primaryButtons.
  ///
  /// In en, this message translates to:
  /// **'Primary Buttons'**
  String get primaryButtons;

  /// No description provided for @secondaryButtons.
  ///
  /// In en, this message translates to:
  /// **'Secondary Buttons'**
  String get secondaryButtons;

  /// No description provided for @tertiaryButtons.
  ///
  /// In en, this message translates to:
  /// **'Tertiary Buttons'**
  String get tertiaryButtons;

  /// No description provided for @statusButtons.
  ///
  /// In en, this message translates to:
  /// **'Status Buttons'**
  String get statusButtons;

  /// No description provided for @toggleButtons.
  ///
  /// In en, this message translates to:
  /// **'Toggle Buttons'**
  String get toggleButtons;

  /// No description provided for @iconButtons.
  ///
  /// In en, this message translates to:
  /// **'Icon Buttons'**
  String get iconButtons;

  /// No description provided for @tertiaryWithIcons.
  ///
  /// In en, this message translates to:
  /// **'Tertiary with Icons'**
  String get tertiaryWithIcons;

  /// No description provided for @normalTextField.
  ///
  /// In en, this message translates to:
  /// **'Normal Text Field'**
  String get normalTextField;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter text...'**
  String get enterText;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description...'**
  String get enterDescription;

  /// No description provided for @searchComponents.
  ///
  /// In en, this message translates to:
  /// **'Search components...'**
  String get searchComponents;

  /// No description provided for @disabledField.
  ///
  /// In en, this message translates to:
  /// **'Disabled Field'**
  String get disabledField;

  /// No description provided for @fieldDisabled.
  ///
  /// In en, this message translates to:
  /// **'This field is disabled'**
  String get fieldDisabled;

  /// No description provided for @valueCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Value cannot be changed'**
  String get valueCannotBeChanged;

  /// No description provided for @confirmDialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Dialog'**
  String get confirmDialog;

  /// No description provided for @inputDialog.
  ///
  /// In en, this message translates to:
  /// **'Input Dialog'**
  String get inputDialog;

  /// No description provided for @choiceDialog.
  ///
  /// In en, this message translates to:
  /// **'Choice Dialog'**
  String get choiceDialog;

  /// No description provided for @loadingDialog.
  ///
  /// In en, this message translates to:
  /// **'Loading Dialog'**
  String get loadingDialog;

  /// No description provided for @testingToastNotifications.
  ///
  /// In en, this message translates to:
  /// **'Testing toast notifications:'**
  String get testingToastNotifications;

  /// No description provided for @defaultToast.
  ///
  /// In en, this message translates to:
  /// **'Default Toast'**
  String get defaultToast;

  /// No description provided for @successToast.
  ///
  /// In en, this message translates to:
  /// **'Success Toast'**
  String get successToast;

  /// No description provided for @warningToast.
  ///
  /// In en, this message translates to:
  /// **'Warning Toast'**
  String get warningToast;

  /// No description provided for @errorToast.
  ///
  /// In en, this message translates to:
  /// **'Error Toast'**
  String get errorToast;

  /// No description provided for @svgIcons.
  ///
  /// In en, this message translates to:
  /// **'SVG Icons:'**
  String get svgIcons;

  /// No description provided for @indicators.
  ///
  /// In en, this message translates to:
  /// **'Indicators:'**
  String get indicators;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
