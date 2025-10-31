enum ProjectStatus {
  accessible,      // Проект доступен
  inaccessible,    // Проект недоступен
  checking,        // Проверка доступности
  error           // Критическая ошибка
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.accessible:
        return 'Доступен';
      case ProjectStatus.inaccessible:
        return 'Недоступен';
      case ProjectStatus.checking:
        return 'Проверка...';
      case ProjectStatus.error:
        return 'Ошибка';
    }
  }

  String get description {
    switch (this) {
      case ProjectStatus.accessible:
        return 'Проект доступен для работы';
      case ProjectStatus.inaccessible:
        return 'Проект недоступен или перемещен';
      case ProjectStatus.checking:
        return 'Выполняется проверка доступности проекта';
      case ProjectStatus.error:
        return 'Произошла критическая ошибка при работе с проектом';
    }
  }
}