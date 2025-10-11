import 'package:hive/hive.dart';

part 'file_edit.g.dart';

@HiveType(typeId: 4)
class FileEdit {
  @HiveField(0)
  final String filePath;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final String? oldContent;

  @HiveField(3)
  final String? newContent;

  @HiveField(4)
  final int? lineStart;

  @HiveField(5)
  final int? lineEnd;

  FileEdit({
    required this.filePath,
    required this.action,
    this.oldContent,
    this.newContent,
    this.lineStart,
    this.lineEnd,
  });
}
