import 'package:hive/hive.dart';

part 'confluence_settings.g.dart';

@HiveType(typeId: 6)
class ConfluenceSettings {
  @HiveField(0)
  String type;

  @HiveField(1)
  String? baseUrl;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? apiToken;

  @HiveField(4)
  String? username;

  @HiveField(5)
  String? password;

  @HiveField(6)
  String? spaceKey;

  @HiveField(7)
  String? parentPageId;

  @HiveField(8)
  bool isEnabled;

  ConfluenceSettings({
    this.type = 'cloud',
    this.baseUrl,
    this.email,
    this.apiToken,
    this.username,
    this.password,
    this.spaceKey,
    this.parentPageId,
    this.isEnabled = false,
  });
}
