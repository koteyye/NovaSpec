import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/data/models/template.dart';
import 'package:novaspec/data/models/template_type.dart';
import 'package:novaspec/presentation/widgets/dialogs/add_template_type_dialog.dart';
import 'package:novaspec/presentation/widgets/dialogs/add_template_dialog.dart';
import 'package:uuid/uuid.dart';

/// Диалог управления шаблонами
class TemplatesDialog extends ConsumerStatefulWidget {
  const TemplatesDialog({super.key});

  @override
  ConsumerState<TemplatesDialog> createState() => _TemplatesDialogState();
}

class _TemplatesDialogState extends ConsumerState<TemplatesDialog> {
  final _repository = ConfigRepository(HiveDataSource());
  final _uuid = const Uuid();

  List<TemplateType> _templateTypes = [];
  List<Template> _templates = [];
  TemplateType? _selectedType;
  Template? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final config = await _repository.getConfig();
    if (config != null && mounted) {
      setState(() {
        _templateTypes = config.templateTypes;
        _templates = config.templates;
        if (_templateTypes.isNotEmpty) {
          _selectedType = _templateTypes.first;
        }
        if (_filteredTemplates.isNotEmpty) {
          _selectedTemplate = _filteredTemplates.first;
        }
      });
    }
  }

  List<Template> get _filteredTemplates {
    if (_selectedType == null) return [];
    return _templates.where((t) => t.typeId == _selectedType!.id).toList();
  }

  // ===== Управление типами шаблонов =====

  Future<void> _createTemplateType() async {
    final result = await AddTemplateTypeDialog.showCreate(context);
    if (result != null) {
      final newType = TemplateType(
        id: _uuid.v4(),
        name: result.name,
        systemName: result.systemName,
        isDefault: false,
      );

      final config = await _repository.getConfig();
      if (config != null) {
        config.templateTypes.add(newType);
        await _repository.updateConfig(config);
        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Тип "${newType.name}" создан')),
          );
        }
      }
    }
  }

  Future<void> _editTemplateType() async {
    if (_selectedType == null) return;

    final result = await AddTemplateTypeDialog.showEdit(context, _selectedType!);
    if (result != null) {
      final config = await _repository.getConfig();
      if (config != null) {
        final index = config.templateTypes.indexWhere((t) => t.id == _selectedType!.id);
        if (index != -1) {
          config.templateTypes[index] = TemplateType(
            id: _selectedType!.id,
            name: result.name,
            systemName: result.systemName,
            isDefault: _selectedType!.isDefault,
          );
          await _repository.updateConfig(config);
          await _loadData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Тип "${result.name}" обновлен')),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteTemplateType() async {
    if (_selectedType == null || _selectedType!.isDefault) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тип шаблона'),
        content: Text(
          'Удалить тип "${_selectedType!.name}"?\n\nВсе шаблоны этого типа также будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final config = await _repository.getConfig();
      if (config != null) {
        config.templateTypes.removeWhere((t) => t.id == _selectedType!.id);
        config.templates.removeWhere((t) => t.typeId == _selectedType!.id);
        await _repository.updateConfig(config);
        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Тип "${_selectedType!.name}" удален')),
          );
        }
      }
    }
  }

  // ===== Управление шаблонами =====

  Future<void> _createTemplate() async {
    if (_selectedType == null) return;

    final result = await AddTemplateDialog.showCreate(context, _selectedType!);
    if (result != null) {
      final newTemplate = Template(
        id: _uuid.v4(),
        name: result.name,
        typeId: _selectedType!.id,
        content: result.content,
        isDefault: false,
      );

      await _repository.addTemplate(newTemplate);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Шаблон "${newTemplate.name}" создан')),
        );
      }
    }
  }

  Future<void> _editTemplate() async {
    if (_selectedTemplate == null || _selectedType == null) return;

    final result = await AddTemplateDialog.showEdit(
      context,
      _selectedTemplate!,
      _selectedType!,
    );

    if (result != null) {
      final updatedTemplate = Template(
        id: _selectedTemplate!.id,
        name: result.name,
        typeId: _selectedTemplate!.typeId,
        content: result.content,
        isDefault: _selectedTemplate!.isDefault,
      );

      await _repository.updateTemplate(updatedTemplate);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Шаблон "${updatedTemplate.name}" обновлен')),
        );
      }
    }
  }

  Future<void> _deleteTemplate() async {
    if (_selectedTemplate == null || _selectedTemplate!.isDefault) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить шаблон'),
        content: Text('Удалить шаблон "${_selectedTemplate!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteTemplate(_selectedTemplate!.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Шаблон "${_selectedTemplate!.name}" удален')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Управление шаблонами', style: NsTextStyles.h2(context)),
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
                  // Left - Template Types
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: isDark ? NsColorsDark.border : NsColorsLight.border,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Section header with actions
                          Container(
                            padding: const EdgeInsets.all(NsSpacing.md),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? NsColorsDark.border
                                      : NsColorsLight.border,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Типы шаблонов',
                                    style: NsTextStyles.h4(context),
                                  ),
                                ),
                                // Action buttons
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: _createTemplateType,
                                  tooltip: 'Добавить тип',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: NsSpacing.xs),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed:
                                      _selectedType != null ? _editTemplateType : null,
                                  tooltip: 'Редактировать тип',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: NsSpacing.xs),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: (_selectedType != null &&
                                          !_selectedType!.isDefault)
                                      ? _deleteTemplateType
                                      : null,
                                  tooltip: 'Удалить тип',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                          // Template types list
                          Expanded(
                            child: ListView.builder(
                              itemCount: _templateTypes.length,
                              itemBuilder: (context, index) {
                                final type = _templateTypes[index];
                                final isSelected = _selectedType?.id == type.id;

                                return ListTile(
                                  title: Text(type.name),
                                  subtitle: type.isDefault
                                      ? const Text('По умолчанию')
                                      : null,
                                  selected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedType = type;
                                      _selectedTemplate = null;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right - Templates
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section header with actions
                        Container(
                          padding: const EdgeInsets.all(NsSpacing.md),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? NsColorsDark.border
                                    : NsColorsLight.border,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Шаблоны',
                                  style: NsTextStyles.h4(context),
                                ),
                              ),
                              // Action buttons
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed:
                                    _selectedType != null ? _createTemplate : null,
                                tooltip: 'Добавить шаблон',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: NsSpacing.xs),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed:
                                    _selectedTemplate != null ? _editTemplate : null,
                                tooltip: 'Редактировать шаблон',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: NsSpacing.xs),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: (_selectedTemplate != null &&
                                        !_selectedTemplate!.isDefault)
                                    ? _deleteTemplate
                                    : null,
                                tooltip: 'Удалить шаблон',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                        // Templates list
                        Expanded(
                          child: _selectedType == null
                              ? Center(
                                  child: Text(
                                    'Выберите тип шаблона',
                                    style: NsTextStyles.bodyLarge(context).copyWith(
                                      color: isDark
                                          ? NsColorsDark.mutedForeground
                                          : NsColorsLight.mutedForeground,
                                    ),
                                  ),
                                )
                              : _filteredTemplates.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 48,
                                            color: isDark
                                                ? NsColorsDark.mutedForeground
                                                : NsColorsLight.mutedForeground,
                                          ),
                                          const SizedBox(height: NsSpacing.md),
                                          Text(
                                            'Нет шаблонов',
                                            style: NsTextStyles.bodyLarge(context)
                                                .copyWith(
                                              color: isDark
                                                  ? NsColorsDark.mutedForeground
                                                  : NsColorsLight.mutedForeground,
                                            ),
                                          ),
                                          const SizedBox(height: NsSpacing.sm),
                                          Text(
                                            'Нажмите + для создания',
                                            style: NsTextStyles.bodySmall(context)
                                                .copyWith(
                                              color: isDark
                                                  ? NsColorsDark.mutedForeground
                                                  : NsColorsLight.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _filteredTemplates.length,
                                      itemBuilder: (context, index) {
                                        final template = _filteredTemplates[index];
                                        final isSelected =
                                            _selectedTemplate?.id == template.id;

                                        return ListTile(
                                          title: Text(template.name),
                                          subtitle: template.isDefault
                                              ? const Text('По умолчанию')
                                              : null,
                                          selected: isSelected,
                                          onTap: () {
                                            setState(() {
                                              _selectedTemplate = template;
                                            });
                                          },
                                        );
                                      },
                                    ),
                        ),
                      ],
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NsButton(
                    text: 'Закрыть',
                    onPressed: () => Navigator.of(context).pop(),
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
