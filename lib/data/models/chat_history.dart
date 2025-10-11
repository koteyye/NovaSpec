import 'package:hive/hive.dart';
import 'package:novaspec/data/models/chat_message.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 11)
class ChatHistory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<ChatMessage> messages;

  @HiveField(3)
  final DateTime createdAt;

  ChatHistory({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
    required this.createdAt,
  }) : messages = messages ?? [];

  void addMessage(ChatMessage message) {
    messages.add(message);
  }
}
