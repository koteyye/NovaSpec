import 'package:hive/hive.dart';

part 'template_type.g.dart';

@HiveType(typeId: 12)
class TemplateType {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Отображаемое имя

  @HiveField(2)
  final String systemName; // Системное имя

  @HiveField(3)
  final bool isDefault; // Если true, нельзя удалить

  TemplateType({
    required this.id,
    required this.name,
    required this.systemName,
    required this.isDefault,
  });
}
