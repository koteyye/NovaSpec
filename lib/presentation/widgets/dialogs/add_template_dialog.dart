import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';
import 'package:novaspec/presentation/widgets/inputs/ns_text_field.dart';
import 'package:novaspec/data/models/template.dart';
import 'package:novaspec/data/models/template_type.dart';

/// Диалог добавления/редактирования шаблона с AI-ревью
class AddTemplateDialog extends StatefulWidget {
  final Template? existingTemplate;
  final TemplateType templateType;

  const AddTemplateDialog({
    super.key,
    this.existingTemplate,
    required this.templateType,
  });

  /// Показать диалог создания нового шаблона
  static Future<Template?> showCreate(
    BuildContext context,
    TemplateType templateType,
  ) {
    return showDialog<Template>(
      context: context,
      builder: (context) => AddTemplateDialog(templateType: templateType),
    );
  }

  /// Показать диалог редактирования шаблона
  static Future<Template?> showEdit(
    BuildContext context,
    Template template,
    TemplateType templateType,
  ) {
    return showDialog<Template>(
      context: context,
      builder: (context) => AddTemplateDialog(
        existingTemplate: template,
        templateType: templateType,
      ),
    );
  }

  @override
  State<AddTemplateDialog> createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<AddTemplateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _contentController;

  bool _isLoading = false;
  bool _isReviewingWithAI = false;
  String? _aiReviewResult;
  bool _hasCriticalIssues = false;
  bool _reviewPassed = false;
  String _selectedModel = 'gpt-4o';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTemplate?.name ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingTemplate?.content ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendToAIReview() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните содержимое шаблона')),
      );
      return;
    }

    setState(() {
      _isReviewingWithAI = true;
      _aiReviewResult = null;
      _hasCriticalIssues = false;
      _reviewPassed = false;
    });

    try {
      // TODO: Здесь будет реальная интеграция с AI через SSE
      // Промпт из спецификации:
      /*
      Ты AI-ассистент в программе NovaSpec, и в рамках данного запроса пользователь отправляет тебе на ревью свой шаблон {template_type}.
      Ты как методолог системных/бизнес аналитиков должен провести ревью шаблона и дать свою экспертную оценку и рекомендации по изменению шаблона.
      В рамках своей экспертной оценки ты должен разделить свои комментарии на критические и рекомендации.
      Критические указываешь, если в шаблоне есть явные несостыковки, которые могут привести генерацию артефакта по данному шаблону к негативным последствиям
      А рекомендации, если это не сильно повлияет на конечный результат.
      Если есть критические замечания, то в ответе обязательно указывай тег @critical_alert, тогда приложение посчитает, что AI-ревью не пройдено и пользователь не сможет сохранить шаблон.
      Относись к критическим замечаниям максимально серьезно! Не стоит по мелочам проставлять замечание как критическое, иначе пользователь перестанет воспринимать тебя всерьез
      */

      // Заглушка для демонстрации функционала
      await Future.delayed(const Duration(seconds: 2));

      // Симуляция ответа AI (в реальности будет SSE стриминг)
      const mockReview = '''
## Результаты ревью шаблона

### ✅ Положительные моменты:
- Структура шаблона логичная и понятная
- Используется правильная терминология
- Присутствуют все необходимые разделы

### 💡 Рекомендации:
- Рекомендую добавить раздел "Критерии приемки"
- Можно уточнить требования к оформлению
- Стоит добавить примеры использования

Шаблон готов к использованию! Замечания носят рекомендательный характер.
''';

      if (mounted) {
        setState(() {
          _aiReviewResult = mockReview;
          _hasCriticalIssues = mockReview.contains('@critical_alert');
          _reviewPassed = !_hasCriticalIssues;
          _isReviewingWithAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReviewingWithAI = false;
          _aiReviewResult = 'Ошибка при получении ревью: $e';
        });
      }
    }
  }

  void _showModelSelector() {
    // TODO: Здесь будет Popover со списком моделей из AI провайдера
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выбор модели'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('gpt-4o'),
                selected: _selectedModel == 'gpt-4o',
                onTap: () {
                  setState(() {
                    _selectedModel = 'gpt-4o';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('claude-3-5-sonnet'),
                selected: _selectedModel == 'claude-3-5-sonnet',
                onTap: () {
                  setState(() {
                    _selectedModel = 'claude-3-5-sonnet';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('gpt-4o-mini'),
                selected: _selectedModel == 'gpt-4o-mini',
                onTap: () {
                  setState(() {
                    _selectedModel = 'gpt-4o-mini';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save({bool skipReview = false}) async {
    // Валидация
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название шаблона')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите содержимое шаблона')),
      );
      return;
    }

    // Если есть критические замечания и не пропускаем ревью, не даем сохранить
    if (_hasCriticalIssues && !skipReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Исправьте критические замечания перед сохранением'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = Template(
        id: widget.existingTemplate?.id ?? '',
        name: _nameController.text.trim(),
        typeId: widget.templateType.id,
        content: _contentController.text.trim(),
        isDefault: widget.existingTemplate?.isDefault ?? false,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingTemplate != null;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        child: Column(
          children: [
              // Header
              Container(
                padding: const EdgeInsets.all(NsSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? NsColorsDark.border : NsColorsLight.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Редактировать шаблон' : 'Добавить шаблон',
                            style: NsTextStyles.h3(context),
                          ),
                          const SizedBox(height: NsSpacing.xs),
                          Text(
                            'Тип: ${widget.templateType.name}',
                            style: NsTextStyles.bodySmall(context).copyWith(
                              color: isDark
                                  ? NsColorsDark.mutedForeground
                                  : NsColorsLight.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Row(
                  children: [
                    // Left - Editor
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(NsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            NsTextField(
                              controller: _nameController,
                              label: 'Название шаблона',
                              hint: 'Например: User Story One Page',
                              enabled: !_isLoading && !_isReviewingWithAI,
                            ),
                            const SizedBox(height: NsSpacing.md),
                            Text(
                              'Содержимое шаблона',
                              style: NsTextStyles.bodyMedium(context),
                            ),
                            const SizedBox(height: NsSpacing.sm),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? NsColorsDark.border
                                        : NsColorsLight.border,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _contentController,
                                  maxLines: null,
                                  expands: true,
                                  enabled: !_isLoading && !_isReviewingWithAI,
                                  decoration: const InputDecoration(
                                    hintText: 'Введите содержимое шаблона в формате Markdown...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(NsSpacing.md),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      color: isDark ? NsColorsDark.border : NsColorsLight.border,
                    ),

                    // Right - AI Review
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(NsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology_outlined,
                                  size: 20,
                                  color: isDark
                                      ? NsColorsDark.primary
                                      : NsColorsLight.primary,
                                ),
                                const SizedBox(width: NsSpacing.sm),
                                Text(
                                  'AI-ревью',
                                  style: NsTextStyles.h4(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: NsSpacing.md),

                            // Model selector
                            InkWell(
                              onTap: _showModelSelector,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: NsSpacing.sm,
                                  vertical: NsSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? NsColorsDark.border
                                        : NsColorsLight.border,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'model: ',
                                      style: NsTextStyles.bodySmall(context).copyWith(
                                        color: isDark
                                            ? NsColorsDark.mutedForeground
                                            : NsColorsLight.mutedForeground,
                                      ),
                                    ),
                                    Text(
                                      _selectedModel,
                                      style: NsTextStyles.bodySmall(context).copyWith(
                                        color: isDark
                                            ? NsColorsDark.primary
                                            : NsColorsLight.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: NsSpacing.xs),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 16,
                                      color: isDark
                                          ? NsColorsDark.mutedForeground
                                          : NsColorsLight.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: NsSpacing.md),

                            // Review button
                            NsButton(
                              text: 'Отправить на ревью',
                              onPressed: _isReviewingWithAI ? null : _sendToAIReview,
                              loading: _isReviewingWithAI,
                              fullWidth: true,
                              icon: Icon(Icons.send_outlined, size: 16),
                            ),
                            const SizedBox(height: NsSpacing.md),

                            // Review result
                            if (_aiReviewResult != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(NsSpacing.md),
                                  decoration: BoxDecoration(
                                    color: (_hasCriticalIssues
                                            ? (isDark
                                                ? NsColorsDark.destructive
                                                : NsColorsLight.destructive)
                                            : (isDark
                                                ? NsColorsDark.primary
                                                : NsColorsLight.primary))
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _hasCriticalIssues
                                                  ? Icons.error_outline
                                                  : Icons.check_circle_outline,
                                              size: 20,
                                              color: _hasCriticalIssues
                                                  ? (isDark
                                                      ? NsColorsDark.destructive
                                                      : NsColorsLight.destructive)
                                                  : (isDark
                                                      ? NsColorsDark.primary
                                                      : NsColorsLight.primary),
                                            ),
                                            const SizedBox(width: NsSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                _hasCriticalIssues
                                                    ? 'Критические замечания'
                                                    : 'Ревью пройдено',
                                                style: NsTextStyles.bodyMedium(context)
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: _hasCriticalIssues
                                                      ? (isDark
                                                          ? NsColorsDark.destructive
                                                          : NsColorsLight
                                                              .destructive)
                                                      : (isDark
                                                          ? NsColorsDark.primary
                                                          : NsColorsLight.primary),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: NsSpacing.md),
                                        Text(
                                          _aiReviewResult!,
                                          style: NsTextStyles.bodySmall(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Нажмите "Отправить на ревью" для\nполучения оценки от AI',
                                    style: NsTextStyles.bodyMedium(context).copyWith(
                                      color: isDark
                                          ? NsColorsDark.mutedForeground
                                          : NsColorsLight.mutedForeground,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(NsSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? NsColorsDark.border : NsColorsLight.border,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info about default templates
                    if (widget.existingTemplate?.isDefault == true)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: isDark
                                  ? NsColorsDark.mutedForeground
                                  : NsColorsLight.mutedForeground,
                            ),
                            const SizedBox(width: NsSpacing.xs),
                            Expanded(
                              child: Text(
                                'Шаблон по умолчанию',
                                style: NsTextStyles.bodySmall(context).copyWith(
                                  color: isDark
                                      ? NsColorsDark.mutedForeground
                                      : NsColorsLight.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),

                    // Action buttons
                    Row(
                      children: [
                        NsButton(
                          text: 'Отмена',
                          onPressed: _isLoading || _isReviewingWithAI
                              ? null
                              : () => Navigator.of(context).pop(),
                          variant: ButtonVariant.secondary,
                        ),
                        const SizedBox(width: NsSpacing.md),
                        NsButton(
                          text: 'Сохранить без ревью',
                          onPressed: _isLoading || _isReviewingWithAI
                              ? null
                              : () => _save(skipReview: true),
                          variant: ButtonVariant.secondary,
                        ),
                        const SizedBox(width: NsSpacing.md),
                        NsButton(
                          text: isEditing ? 'Сохранить' : 'Создать',
                          onPressed: (_isLoading ||
                                  _isReviewingWithAI ||
                                  (_hasCriticalIssues && !_reviewPassed))
                              ? null
                              : _save,
                          loading: _isLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
