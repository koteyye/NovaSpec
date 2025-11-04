enum FileViewMode {
  view,
  edit,
  preview,
}

extension FileViewModeExtension on FileViewMode {
  String get displayName {
    switch (this) {
      case FileViewMode.view:
        return 'Просмотр';
      case FileViewMode.edit:
        return 'Редактирование';
      case FileViewMode.preview:
        return 'Предпросмотр';
    }
  }

  String get iconPath {
    switch (this) {
      case FileViewMode.view:
        return 'assets/images/icons/view.svg';
      case FileViewMode.edit:
        return 'assets/images/icons/edit.svg';
      case FileViewMode.preview:
        return 'assets/images/icons/preview.svg';
    }
  }

  bool get isEditable => this == FileViewMode.edit;
  bool get isViewMode => this == FileViewMode.view;
  bool get isPreviewMode => this == FileViewMode.preview;
}