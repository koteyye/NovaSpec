// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NovaSpec';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get close => 'Close';

  @override
  String get projects => 'Projects';

  @override
  String get settings => 'Settings';

  @override
  String get workspace => 'Workspace';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get fileExplorer => 'File Explorer';

  @override
  String get templates => 'Templates';

  @override
  String get newProject => 'New Project';

  @override
  String get openProject => 'Open Project';

  @override
  String get recentProjects => 'Recent Projects';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectDescription => 'Project Description';

  @override
  String get projectManagement => 'Project Management';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get about => 'About';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get files => 'Files';

  @override
  String get folders => 'Folders';

  @override
  String get createFile => 'Create File';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get rename => 'Rename';

  @override
  String get copy => 'Copy';

  @override
  String get cut => 'Cut';

  @override
  String get newName => 'New name';

  @override
  String get folderName => 'Folder name';

  @override
  String get file => 'file';

  @override
  String get folder => 'folder';

  @override
  String confirmDelete(Object name, Object type) {
    return 'Are you sure you want to delete $type \"$name\"?';
  }

  @override
  String get createNewFile => 'Create New File';

  @override
  String get fileName => 'File name';

  @override
  String get enterFileName => 'Enter file name';

  @override
  String get fileType => 'File type';

  @override
  String get template => 'Template';

  @override
  String get creating => 'Creating...';

  @override
  String get enterFileNameError => 'Enter file name';

  @override
  String get invalidFileNameError => 'File name contains invalid characters';

  @override
  String fileCreated(Object fileName) {
    return 'File \"$fileName\" created';
  }

  @override
  String createFileError(Object error) {
    return 'Error creating file: $error';
  }

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToRussian => 'Switch to Russian';

  @override
  String get svgIconsTest => 'SVG Icons Test';

  @override
  String get homeScreen => 'Home Screen';

  @override
  String get workspaceScreen => 'Workspace Screen';

  @override
  String get projectManagementScreen => 'Project Management Screen';

  @override
  String get settingsScreen => 'Settings Screen';

  @override
  String get aiAssistantScreen => 'AI Assistant Screen';

  @override
  String get fileExplorerScreen => 'File Explorer Screen';

  @override
  String get templatesScreen => 'Templates Screen';

  @override
  String get specPreview => 'Spec Preview';

  @override
  String get specContent => 'Spec Content';

  @override
  String get textEditor => 'Text Editor';

  @override
  String get initialContent => 'Initial Content';

  @override
  String get swaggerUrl => 'Swagger URL';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get noOpenProject => 'No Open Project';

  @override
  String get workspaceComingSoon => 'Workspace will be available soon';

  @override
  String get workspaceNextVersion =>
      'Workspace will be available in the next version';

  @override
  String get appTitle => 'NovaSpec - Phase 2 Complete';

  @override
  String get languageTest => 'Language Test (en)';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get notifications => 'Notifications';

  @override
  String get autoSaveDescription => 'Automatically save changes';

  @override
  String get notificationsDescription => 'Show app notifications';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all settings to default values?';

  @override
  String get reset => 'Reset';

  @override
  String get language => 'Language';

  @override
  String get save => 'Save';

  @override
  String get errorLoadingSettings => 'Error loading settings';

  @override
  String get errorSavingSettings => 'Error saving settings';

  @override
  String get errorResettingSettings => 'Error resetting settings';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get settingsReset => 'Settings reset to defaults';

  @override
  String get back => 'Back';

  @override
  String get componentDemo => 'Component Demo';

  @override
  String get buttons => 'Buttons';

  @override
  String get textFields => 'Text Fields';

  @override
  String get dialogs => 'Dialogs';

  @override
  String get toastNotifications => 'Toast Notifications';

  @override
  String get otherComponents => 'Other Components';

  @override
  String get primaryButtons => 'Primary Buttons';

  @override
  String get secondaryButtons => 'Secondary Buttons';

  @override
  String get tertiaryButtons => 'Tertiary Buttons';

  @override
  String get statusButtons => 'Status Buttons';

  @override
  String get toggleButtons => 'Toggle Buttons';

  @override
  String get iconButtons => 'Icon Buttons';

  @override
  String get tertiaryWithIcons => 'Tertiary with Icons';

  @override
  String get normalTextField => 'Normal Text Field';

  @override
  String get enterText => 'Enter text...';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get description => 'Description';

  @override
  String get enterDescription => 'Enter description...';

  @override
  String get searchComponents => 'Search components...';

  @override
  String get disabledField => 'Disabled Field';

  @override
  String get fieldDisabled => 'This field is disabled';

  @override
  String get valueCannotBeChanged => 'Value cannot be changed';

  @override
  String get confirmDialog => 'Confirm Dialog';

  @override
  String get inputDialog => 'Input Dialog';

  @override
  String get choiceDialog => 'Choice Dialog';

  @override
  String get loadingDialog => 'Loading Dialog';

  @override
  String get testingToastNotifications => 'Testing toast notifications:';

  @override
  String get defaultToast => 'Default Toast';

  @override
  String get successToast => 'Success Toast';

  @override
  String get warningToast => 'Warning Toast';

  @override
  String get errorToast => 'Error Toast';

  @override
  String get svgIcons => 'SVG Icons:';

  @override
  String get indicators => 'Indicators:';

  @override
  String get active => 'Active';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get parameters => 'Parameters';

  @override
  String get aiProviders => 'AI Providers';

  @override
  String get openAi => 'OpenAI';

  @override
  String get claude => 'Claude';

  @override
  String get gemini => 'Gemini';

  @override
  String get deepseek => 'DeepSeek';

  @override
  String get ollama => 'Ollama';

  @override
  String get lmStudio => 'LM Studio';

  @override
  String get zAi => 'Z.AI';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get enterBaseUrl => 'Enter base URL...';

  @override
  String get enterApiKey => 'Enter API key...';

  @override
  String get confluenceIntegration => 'Confluence Integration';

  @override
  String get confluenceUrl => 'Confluence URL';

  @override
  String get confluenceUsername => 'Confluence Username';

  @override
  String get confluenceToken => 'Confluence Token';

  @override
  String get enterConfluenceUrl => 'Enter Confluence URL...';

  @override
  String get enterConfluenceUsername => 'Enter Confluence username...';

  @override
  String get enterConfluenceToken => 'Enter Confluence token...';

  @override
  String get musicIntegration => 'Music Integration';

  @override
  String get musicProvider => 'Music Provider';

  @override
  String get spotify => 'Spotify';

  @override
  String get youtubeMusic => 'YouTube Music';

  @override
  String get musicGenre => 'Music Genre';

  @override
  String get classical => 'Classical';

  @override
  String get jazz => 'Jazz';

  @override
  String get electronic => 'Electronic';

  @override
  String get rock => 'Rock';

  @override
  String get pop => 'Pop Music';

  @override
  String get hipHop => 'Hip Hop';

  @override
  String get ambient => 'Ambient';

  @override
  String get loFi => 'Lo-Fi';

  @override
  String get zAiAccessType => 'Z.AI Access Type';

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testing => 'Testing...';

  @override
  String get connectionSuccessful => 'Connection successful!';

  @override
  String get connectionFailed => 'Connection failed!';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String get invalidApiKey => 'Invalid API key format';

  @override
  String get tokenRequired => 'API token is required';

  @override
  String get urlRequired => 'Base URL is required';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get confluenceUrlRequired => 'Confluence URL is required';

  @override
  String get confluenceTokenRequired => 'Confluence token is required';

  @override
  String projectCreatedSuccessfully(Object projectName) {
    return 'Project \"$projectName\" created successfully';
  }

  @override
  String failedToCreateProject(Object error) {
    return 'Failed to create project: $error';
  }

  @override
  String get noProjectToSave => 'No project to save';

  @override
  String get projectSavedSuccessfully => 'Project saved successfully';

  @override
  String failedToSaveProject(Object error) {
    return 'Failed to save project: $error';
  }

  @override
  String projectSavedAsSuccessfully(Object projectName) {
    return 'Project saved successfully as \"$projectName\"';
  }

  @override
  String failedToSaveProjectAs(Object error) {
    return 'Failed to save project as: $error';
  }

  @override
  String get projectFileInaccessible => 'Project file became inaccessible';

  @override
  String get projectFileAccessible => 'Project file is accessible again';

  @override
  String get projectFolderInaccessible => 'Project folder became inaccessible';

  @override
  String get projectFolderAccessible => 'Project folder is accessible again';

  @override
  String folderProjectOpenedSuccessfully(Object projectName) {
    return 'Folder project \"$projectName\" opened successfully';
  }

  @override
  String failedToOpenFolderProject(Object error) {
    return 'Failed to open folder project: $error';
  }

  @override
  String get projectStatusAccessible => 'Accessible';

  @override
  String get projectStatusInaccessible => 'Inaccessible';

  @override
  String get projectStatusError => 'Error';

  @override
  String get projectStatusSynced => 'Synced';

  @override
  String get projectStatusConflict => 'Conflict';

  @override
  String get projectStatusPending => 'Pending';

  @override
  String get projectStatusOffline => 'Offline';

  @override
  String get expandFileExplorerPanel => 'Expand file explorer panel';

  @override
  String get collapseFileExplorerPanel => 'Collapse file explorer panel';

  @override
  String get refresh => 'Refresh';
}
