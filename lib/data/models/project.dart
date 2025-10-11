import 'package:hive/hive.dart';
import 'package:novaspec/data/models/project_settings.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  final String rootPath;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  ProjectSettings settings;

  @HiveField(7)
  List<String> conversationIds;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.rootPath,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    List<String>? conversationIds,
  }) : conversationIds = conversationIds ?? [];

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
