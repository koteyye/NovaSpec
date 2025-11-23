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

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get file;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'folder'**
  String get folder;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {type} \"{name}\"?'**
  String confirmDelete(Object name, Object type);

  /// No description provided for @createNewFile.
  ///
  /// In en, this message translates to:
  /// **'Create New File'**
  String get createNewFile;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @enterFileName.
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get enterFileName;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get fileType;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @enterFileNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get enterFileNameError;

  /// No description provided for @musication.
  ///
  /// In en, this message translates to:
  /// **'Musication'**
  String get musication;

  /// No description provided for @musication_button_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Create music based on text'**
  String get musication_button_tooltip;

  /// No description provided for @musication_select_genre.
  ///
  /// In en, this message translates to:
  /// **'Select genre'**
  String get musication_select_genre;

  /// No description provided for @musication_generating_lyrics.
  ///
  /// In en, this message translates to:
  /// **'Generating song lyrics'**
  String get musication_generating_lyrics;

  /// No description provided for @musication_generating_audio.
  ///
  /// In en, this message translates to:
  /// **'Generating audio'**
  String get musication_generating_audio;

  /// No description provided for @musication_saving_audio.
  ///
  /// In en, this message translates to:
  /// **'Saving audio'**
  String get musication_saving_audio;

  /// No description provided for @musication_completed.
  ///
  /// In en, this message translates to:
  /// **'Musication completed'**
  String get musication_completed;

  /// No description provided for @musication_failed.
  ///
  /// In en, this message translates to:
  /// **'Musication failed'**
  String get musication_failed;

  /// No description provided for @musication_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get musication_cancel;

  /// No description provided for @musication_cancel_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel musication?'**
  String get musication_cancel_confirmation;

  /// No description provided for @musication_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get musication_balance;

  /// No description provided for @musication_insufficient_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get musication_insufficient_balance;

  /// No description provided for @musication_api_key_not_set.
  ///
  /// In en, this message translates to:
  /// **'gen-api.ru API key not set'**
  String get musication_api_key_not_set;

  /// No description provided for @musication_invalid_api_key.
  ///
  /// In en, this message translates to:
  /// **'Invalid gen-api.ru API key'**
  String get musication_invalid_api_key;

  /// No description provided for @musication_generation_timeout.
  ///
  /// In en, this message translates to:
  /// **'Music generation timeout'**
  String get musication_generation_timeout;

  /// No description provided for @musication_select_directory.
  ///
  /// In en, this message translates to:
  /// **'Select directory to save music'**
  String get musication_select_directory;

  /// No description provided for @musication_files_saved.
  ///
  /// In en, this message translates to:
  /// **'Files saved successfully'**
  String get musication_files_saved;

  /// No description provided for @musication_error.
  ///
  /// In en, this message translates to:
  /// **'Musication error'**
  String get musication_error;

  /// No description provided for @musication_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get musication_retry;

  /// No description provided for @musication_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get musication_close;

  /// No description provided for @genre_pop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get genre_pop;

  /// No description provided for @genre_russian_rap.
  ///
  /// In en, this message translates to:
  /// **'Russian rap'**
  String get genre_russian_rap;

  /// No description provided for @genre_rock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get genre_rock;

  /// No description provided for @genre_jazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get genre_jazz;

  /// No description provided for @genre_classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get genre_classic;

  /// No description provided for @genre_electronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic music'**
  String get genre_electronic;

  /// No description provided for @genre_hiphop.
  ///
  /// In en, this message translates to:
  /// **'Hip-hop'**
  String get genre_hiphop;

  /// No description provided for @genre_rnb.
  ///
  /// In en, this message translates to:
  /// **'R&B'**
  String get genre_rnb;

  /// No description provided for @invalidFileNameError.
  ///
  /// In en, this message translates to:
  /// **'File name contains invalid characters'**
  String get invalidFileNameError;

  /// No description provided for @fileCreated.
  ///
  /// In en, this message translates to:
  /// **'File \"{fileName}\" created'**
  String fileCreated(Object fileName);

  /// No description provided for @createFileError.
  ///
  /// In en, this message translates to:
  /// **'Error creating file: {error}'**
  String createFileError(Object error);

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

  /// No description provided for @noOpenProject.
  ///
  /// In en, this message translates to:
  /// **'No Open Project'**
  String get noOpenProject;

  /// No description provided for @workspaceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Workspace will be available soon'**
  String get workspaceComingSoon;

  /// No description provided for @workspaceNextVersion.
  ///
  /// In en, this message translates to:
  /// **'Workspace will be available in the next version'**
  String get workspaceNextVersion;

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

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @aiProviders.
  ///
  /// In en, this message translates to:
  /// **'AI Providers'**
  String get aiProviders;

  /// No description provided for @openAi.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get openAi;

  /// No description provided for @claude.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get claude;

  /// No description provided for @gemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get gemini;

  /// No description provided for @deepseek.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek'**
  String get deepseek;

  /// No description provided for @ollama.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get ollama;

  /// No description provided for @lmStudio.
  ///
  /// In en, this message translates to:
  /// **'LM Studio'**
  String get lmStudio;

  /// No description provided for @zAi.
  ///
  /// In en, this message translates to:
  /// **'Z.AI'**
  String get zAi;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @enterBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter base URL...'**
  String get enterBaseUrl;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter API key...'**
  String get enterApiKey;

  /// No description provided for @confluenceIntegration.
  ///
  /// In en, this message translates to:
  /// **'Confluence Integration'**
  String get confluenceIntegration;

  /// No description provided for @confluenceUrl.
  ///
  /// In en, this message translates to:
  /// **'Confluence URL'**
  String get confluenceUrl;

  /// No description provided for @confluenceUsername.
  ///
  /// In en, this message translates to:
  /// **'Confluence Username'**
  String get confluenceUsername;

  /// No description provided for @confluenceToken.
  ///
  /// In en, this message translates to:
  /// **'Confluence Token'**
  String get confluenceToken;

  /// No description provided for @enterConfluenceUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter Confluence URL...'**
  String get enterConfluenceUrl;

  /// No description provided for @enterConfluenceUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Confluence username...'**
  String get enterConfluenceUsername;

  /// No description provided for @enterConfluenceToken.
  ///
  /// In en, this message translates to:
  /// **'Enter Confluence token...'**
  String get enterConfluenceToken;

  /// No description provided for @musicIntegration.
  ///
  /// In en, this message translates to:
  /// **'Music Integration'**
  String get musicIntegration;

  /// No description provided for @musicProvider.
  ///
  /// In en, this message translates to:
  /// **'Music Provider'**
  String get musicProvider;

  /// No description provided for @spotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get spotify;

  /// No description provided for @youtubeMusic.
  ///
  /// In en, this message translates to:
  /// **'YouTube Music'**
  String get youtubeMusic;

  /// No description provided for @musicGenre.
  ///
  /// In en, this message translates to:
  /// **'Music Genre'**
  String get musicGenre;

  /// No description provided for @classical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get classical;

  /// No description provided for @jazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get jazz;

  /// No description provided for @electronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get electronic;

  /// No description provided for @rock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get rock;

  /// No description provided for @pop.
  ///
  /// In en, this message translates to:
  /// **'Pop Music'**
  String get pop;

  /// No description provided for @hipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip Hop'**
  String get hipHop;

  /// No description provided for @ambient.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get ambient;

  /// No description provided for @loFi.
  ///
  /// In en, this message translates to:
  /// **'Lo-Fi'**
  String get loFi;

  /// No description provided for @zAiAccessType.
  ///
  /// In en, this message translates to:
  /// **'Z.AI Access Type'**
  String get zAiAccessType;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection successful!'**
  String get connectionSuccessful;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed!'**
  String get connectionFailed;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL format'**
  String get invalidUrl;

  /// No description provided for @invalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key format'**
  String get invalidApiKey;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'API token is required'**
  String get tokenRequired;

  /// No description provided for @urlRequired.
  ///
  /// In en, this message translates to:
  /// **'Base URL is required'**
  String get urlRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @confluenceUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Confluence URL is required'**
  String get confluenceUrlRequired;

  /// No description provided for @confluenceTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Confluence token is required'**
  String get confluenceTokenRequired;

  /// No description provided for @projectCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Project \"{projectName}\" created successfully'**
  String projectCreatedSuccessfully(Object projectName);

  /// No description provided for @failedToCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project: {error}'**
  String failedToCreateProject(Object error);

  /// No description provided for @noProjectToSave.
  ///
  /// In en, this message translates to:
  /// **'No project to save'**
  String get noProjectToSave;

  /// No description provided for @projectSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Project saved successfully'**
  String get projectSavedSuccessfully;

  /// No description provided for @failedToSaveProject.
  ///
  /// In en, this message translates to:
  /// **'Failed to save project: {error}'**
  String failedToSaveProject(Object error);

  /// No description provided for @projectSavedAsSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Project saved successfully as \"{projectName}\"'**
  String projectSavedAsSuccessfully(Object projectName);

  /// No description provided for @failedToSaveProjectAs.
  ///
  /// In en, this message translates to:
  /// **'Failed to save project as: {error}'**
  String failedToSaveProjectAs(Object error);

  /// No description provided for @projectFileInaccessible.
  ///
  /// In en, this message translates to:
  /// **'Project file became inaccessible'**
  String get projectFileInaccessible;

  /// No description provided for @projectFileAccessible.
  ///
  /// In en, this message translates to:
  /// **'Project file is accessible again'**
  String get projectFileAccessible;

  /// No description provided for @projectFolderInaccessible.
  ///
  /// In en, this message translates to:
  /// **'Project folder became inaccessible'**
  String get projectFolderInaccessible;

  /// No description provided for @projectFolderAccessible.
  ///
  /// In en, this message translates to:
  /// **'Project folder is accessible again'**
  String get projectFolderAccessible;

  /// No description provided for @folderProjectOpenedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Folder project \"{projectName}\" opened successfully'**
  String folderProjectOpenedSuccessfully(Object projectName);

  /// No description provided for @failedToOpenFolderProject.
  ///
  /// In en, this message translates to:
  /// **'Failed to open folder project: {error}'**
  String failedToOpenFolderProject(Object error);

  /// No description provided for @projectStatusAccessible.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get projectStatusAccessible;

  /// No description provided for @projectStatusInaccessible.
  ///
  /// In en, this message translates to:
  /// **'Inaccessible'**
  String get projectStatusInaccessible;

  /// No description provided for @projectStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get projectStatusError;

  /// No description provided for @projectStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get projectStatusSynced;

  /// No description provided for @projectStatusConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get projectStatusConflict;

  /// No description provided for @projectStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get projectStatusPending;

  /// No description provided for @projectStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get projectStatusOffline;

  /// No description provided for @expandFileExplorerPanel.
  ///
  /// In en, this message translates to:
  /// **'Expand file explorer panel'**
  String get expandFileExplorerPanel;

  /// No description provided for @collapseFileExplorerPanel.
  ///
  /// In en, this message translates to:
  /// **'Collapse file explorer panel'**
  String get collapseFileExplorerPanel;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @fileCreationErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied: Cannot create files in \"{directory}\"'**
  String fileCreationErrorPermissionDenied(Object directory);

  /// No description provided for @fileAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'File \"{fileName}\" already exists'**
  String fileAlreadyExists(Object fileName);

  /// No description provided for @invalidFileName.
  ///
  /// In en, this message translates to:
  /// **'Invalid file name: \"{fileName}\"'**
  String invalidFileName(Object fileName);

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied for directory \"{directory}\"'**
  String permissionDenied(Object directory);

  /// No description provided for @directoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Directory not found: \"{directory}\"'**
  String directoryNotFound(Object directory);

  /// No description provided for @diskFull.
  ///
  /// In en, this message translates to:
  /// **'Disk full, cannot create file'**
  String get diskFull;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @fileCreationError.
  ///
  /// In en, this message translates to:
  /// **'File creation error: {error}'**
  String fileCreationError(Object error);
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
