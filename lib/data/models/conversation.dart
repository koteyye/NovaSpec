import 'package:hive/hive.dart';
import 'package:novaspec/data/models/message.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String mode;

  @HiveField(4)
  List<Message> messages;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Conversation({
    required this.id,
    required this.projectId,
    required this.title,
    required this.mode,
    List<Message>? messages,
    required this.createdAt,
    required this.updatedAt,
  }) : messages = messages ?? [];

  void addMessage(Message message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
