enum FileExtension {
  markdown,
  html,
  yaml,
  json,
  mp3,
  wav,
  unknown,
}

extension FileExtensionExtension on FileExtension {
  String get displayName {
    switch (this) {
      case FileExtension.markdown:
        return 'Markdown';
      case FileExtension.html:
        return 'HTML';
      case FileExtension.yaml:
        return 'YAML';
      case FileExtension.json:
        return 'JSON';
      case FileExtension.mp3:
        return 'MP3';
      case FileExtension.wav:
        return 'WAV';
      case FileExtension.unknown:
        return 'Unknown';
    }
  }

  String get iconPath {
    switch (this) {
      case FileExtension.markdown:
        return 'assets/images/file-icons/markdown.svg';
      case FileExtension.html:
        return 'assets/images/file-icons/html.svg';
      case FileExtension.yaml:
        return 'assets/images/file-icons/yaml.svg';
      case FileExtension.json:
        return 'assets/images/file-icons/json.svg';
      case FileExtension.mp3:
        return 'assets/images/file-icons/audio.svg';
      case FileExtension.wav:
        return 'assets/images/file-icons/audio.svg';
      case FileExtension.unknown:
        return 'assets/images/file-icons/unknown.svg';
    }
  }

  List<String> get extensions {
    switch (this) {
      case FileExtension.markdown:
        return ['md', 'markdown'];
      case FileExtension.html:
        return ['html', 'htm'];
      case FileExtension.yaml:
        return ['yaml', 'yml'];
      case FileExtension.json:
        return ['json'];
      case FileExtension.mp3:
        return ['mp3'];
      case FileExtension.wav:
        return ['wav'];
      case FileExtension.unknown:
        return [];
    }
  }

  bool get isTextFile => [
    FileExtension.markdown,
    FileExtension.html,
    FileExtension.yaml,
    FileExtension.json,
  ].contains(this);

  bool get isAudioFile => [
    FileExtension.mp3,
    FileExtension.wav,
  ].contains(this);

  bool get isCodeFile => [
    FileExtension.yaml,
    FileExtension.json,
  ].contains(this);

  bool get isDocumentFile => [
    FileExtension.markdown,
    FileExtension.html,
  ].contains(this);
}