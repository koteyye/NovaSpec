import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novaspec/data/models/project.dart';
import 'package:novaspec/data/models/project_settings.dart';
import 'package:novaspec/data/models/conversation.dart';
import 'package:novaspec/data/models/message.dart';
import 'package:novaspec/data/models/file_edit.dart';
import 'package:novaspec/data/models/ai_provider_config.dart';
import 'package:novaspec/data/models/confluence_settings.dart';
import 'package:novaspec/data/models/chat_message.dart';
import 'package:novaspec/data/models/chat_history.dart';
import 'package:novaspec/data/models/template_type.dart';
import 'package:novaspec/data/models/template.dart';
import 'package:novaspec/data/models/app_config.dart';
import 'package:novaspec/core/config/theme/ns_theme.dart';
import 'package:novaspec/core/config/router/app_router.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрация TypeAdapters
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ProjectSettingsAdapter());
  Hive.registerAdapter(ConversationAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(FileEditAdapter());
  Hive.registerAdapter(AIProviderConfigAdapter());
  Hive.registerAdapter(ConfluenceSettingsAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatHistoryAdapter());
  Hive.registerAdapter(TemplateTypeAdapter());
  Hive.registerAdapter(TemplateAdapter());
  Hive.registerAdapter(AppConfigAdapter());

  // Открытие boxes
  await Hive.openBox<Project>('projects');
  await Hive.openBox<Conversation>('conversations');
  await Hive.openBox<AIProviderConfig>('ai_providers');
  await Hive.openBox<ConfluenceSettings>('confluence_settings');
  await Hive.openBox<AppConfig>('app_config');
  await Hive.openBox('app_settings');

  // Создаем экземпляр роутера
  final dataSource = HiveDataSource();
  final appRouter = AppRouter(dataSource);

  runApp(
    ProviderScope(
      child: NovaSpecApp(router: appRouter),
    ),
  );
}

class NovaSpecApp extends StatelessWidget {
  final AppRouter router;

  const NovaSpecApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NovaSpec',
      debugShowCheckedModeBanner: false,
      theme: NsTheme.light(),
      darkTheme: NsTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router.router,
    );
  }
}
