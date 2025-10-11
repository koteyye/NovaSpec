import 'package:hive/hive.dart';
import 'package:novaspec/data/models/file_edit.dart';

part 'message.g.dart';

@HiveType(typeId: 3)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final List<FileEdit>? fileEdits;

  @HiveField(6)
  final String? status;

  Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.fileEdits,
    this.status,
  });
}
