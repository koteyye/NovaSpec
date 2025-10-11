import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';
import 'package:novaspec/presentation/widgets/inputs/ns_text_field.dart';
import 'package:novaspec/data/models/template_type.dart';

/// Диалог добавления/редактирования типа шаблона
class AddTemplateTypeDialog extends StatefulWidget {
  final TemplateType? existingType;

  const AddTemplateTypeDialog({
    super.key,
    this.existingType,
  });

  /// Показать диалог создания нового типа шаблона
  static Future<TemplateType?> showCreate(BuildContext context) {
    return showDialog<TemplateType>(
      context: context,
      builder: (context) => const AddTemplateTypeDialog(),
    );
  }

  /// Показать диалог редактирования типа шаблона
  static Future<TemplateType?> showEdit(
    BuildContext context,
    TemplateType type,
  ) {
    return showDialog<TemplateType>(
      context: context,
      builder: (context) => AddTemplateTypeDialog(existingType: type),
    );
  }

  @override
  State<AddTemplateTypeDialog> createState() => _AddTemplateTypeDialogState();
}

class _AddTemplateTypeDialogState extends State<AddTemplateTypeDialog> {
  late TextEditingController _nameController;
  late TextEditingController _systemNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingType?.name ?? '',
    );
    _systemNameController = TextEditingController(
      text: widget.existingType?.systemName ?? '',
    );

    // Автоматически генерировать systemName при вводе name (только для новых)
    if (widget.existingType == null) {
      _nameController.addListener(_generateSystemName);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _systemNameController.dispose();
    super.dispose();
  }

  void _generateSystemName() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      // Транслитерация и преобразование в snake_case
      final systemName = _transliterate(name)
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      if (_systemNameController.text.isEmpty) {
        _systemNameController.text = systemName;
      }
    }
  }

  String _transliterate(String text) {
    const Map<String, String> translitMap = {
      'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd',
      'е': 'e', 'ё': 'yo', 'ж': 'zh', 'з': 'z', 'и': 'i',
      'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n',
      'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't',
      'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts', 'ч': 'ch',
      'ш': 'sh', 'щ': 'sch', 'ъ': '', 'ы': 'y', 'ь': '',
      'э': 'e', 'ю': 'yu', 'я': 'ya',
      ' ': '_',
    };

    final buffer = StringBuffer();
    for (var char in text.toLowerCase().split('')) {
      buffer.write(translitMap[char] ?? char);
    }
    return buffer.toString();
  }

  Future<void> _save() async {
    // Валидация
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название типа шаблона')),
      );
      return;
    }

    if (_systemNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите системное имя')),
      );
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(_systemNameController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Только латинские буквы, цифры и подчеркивания')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = TemplateType(
        id: widget.existingType?.id ?? '',
        name: _nameController.text.trim(),
        systemName: _systemNameController.text.trim(),
        isDefault: widget.existingType?.isDefault ?? false,
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
    final isEditing = widget.existingType != null;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      child: Text(
                        isEditing
                            ? 'Редактировать тип шаблона'
                            : 'Добавить тип шаблона',
                        style: NsTextStyles.h3(context),
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
              Padding(
                padding: const EdgeInsets.all(NsSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NsTextField(
                      controller: _nameController,
                      label: 'Название типа шаблона',
                      hint: 'Например: Техническое задание',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: NsSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NsTextField(
                          controller: _systemNameController,
                          label: 'Системное имя',
                          hint: 'Например: technical_specification',
                          enabled: !_isLoading && !isEditing,
                        ),
                        const SizedBox(height: NsSpacing.xs),
                        Text(
                          isEditing
                              ? 'Системное имя нельзя изменить'
                              : 'Используется для внутренней идентификации',
                          style: NsTextStyles.bodySmall(context).copyWith(
                            color: isDark
                                ? NsColorsDark.mutedForeground
                                : NsColorsLight.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    if (widget.existingType?.isDefault == true) ...[
                      const SizedBox(height: NsSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(NsSpacing.md),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? NsColorsDark.primary
                                  : NsColorsLight.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: isDark
                                  ? NsColorsDark.primary
                                  : NsColorsLight.primary,
                            ),
                            const SizedBox(width: NsSpacing.sm),
                            Expanded(
                              child: Text(
                                'Это тип по умолчанию. Его нельзя удалить.',
                                style: NsTextStyles.bodySmall(context).copyWith(
                                  color: isDark
                                      ? NsColorsDark.primary
                                      : NsColorsLight.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NsButton(
                      text: 'Отмена',
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      variant: ButtonVariant.secondary,
                    ),
                    const SizedBox(width: NsSpacing.md),
                    NsButton(
                      text: isEditing ? 'Сохранить' : 'Создать',
                      onPressed: _isLoading ? null : _save,
                      loading: _isLoading,
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
