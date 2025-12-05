import 'package:equatable/equatable.dart';
import '../../../../shared/models/project_file.dart';

class MusicationRequest extends Equatable {
  final String id;
  final String projectPath;
  final String selectedText;
  final String genre;
  final String lyrics;
  final DateTime startedAt;
  final ProjectFile? file;

  const MusicationRequest({
    required this.id,
    required this.projectPath,
    required this.selectedText,
    required this.genre,
    required this.lyrics,
    required this.startedAt,
    this.file,
  });

  factory MusicationRequest.create({
    required String projectPath,
    required String selectedText,
    required String genre,
    required String lyrics,
    ProjectFile? file,
  }) {
    return MusicationRequest(
      id: const String.fromEnvironment('') == ''
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : const String.fromEnvironment(''),
      projectPath: projectPath,
      selectedText: selectedText,
      genre: genre,
      lyrics: lyrics,
      startedAt: DateTime.now(),
      file: file,
    );
  }

  MusicationRequest copyWith({
    String? id,
    String? projectPath,
    String? selectedText,
    String? genre,
    String? lyrics,
    DateTime? startedAt,
    ProjectFile? file,
  }) {
    return MusicationRequest(
      id: id ?? this.id,
      projectPath: projectPath ?? this.projectPath,
      selectedText: selectedText ?? this.selectedText,
      genre: genre ?? this.genre,
      lyrics: lyrics ?? this.lyrics,
      startedAt: startedAt ?? this.startedAt,
      file: file ?? this.file,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_path': projectPath,
      'selected_text': selectedText,
      'genre': genre,
      'lyrics': lyrics,
      'started_at': startedAt.toIso8601String(),
      'file_path': file?.path,
    };
  }

  factory MusicationRequest.fromMap(Map<String, dynamic> map) {
    return MusicationRequest(
      id: map['id'] as String,
      projectPath: map['project_path'] as String,
      selectedText: map['selected_text'] as String,
      genre: map['genre'] as String,
      lyrics: map['lyrics'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      file: map['file_path'] != null
          ? ProjectFile(
              name: '',
              path: map['file_path'] as String,
              size: 0,
              modifiedAt: DateTime.now(),
              type: ProjectFileType.other,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectPath,
    selectedText,
    genre,
    lyrics,
    startedAt,
    file,
  ];
}
