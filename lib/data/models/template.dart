import 'package:hive/hive.dart';

part 'template.g.dart';

@HiveType(typeId: 13)
class Template {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final String typeId;

  @HiveField(3)
  String content;

  @HiveField(4)
  final bool isDefault; // Если true, нельзя удалить

  Template({
    required this.id,
    required this.name,
    required this.typeId,
    required this.content,
    required this.isDefault,
  });
}
