import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 10)
class ChatMessage {
  @HiveField(0)
  final String role; // user | assistant

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
