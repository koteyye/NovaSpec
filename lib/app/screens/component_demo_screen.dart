import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../core/services/toast_service.dart' as toast;

class ComponentDemoScreen extends StatefulWidget {
  const ComponentDemoScreen({super.key});

  @override
  State<ComponentDemoScreen> createState() => _ComponentDemoScreenState();
}

class _ComponentDemoScreenState extends State<ComponentDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isToggleSelected = false;

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Демонстрация UI компонентов'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Кнопки'),
            const SizedBox(height: 12),
            _buildButtonsSection(),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Поля ввода'),
            const SizedBox(height: 12),
            _buildTextFieldsSection(),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Диалоги'),
            const SizedBox(height: 12),
            _buildDialogsSection(),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Toast уведомления'),
            const SizedBox(height: 12),
            _buildToastSection(),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Другие компоненты'),
            const SizedBox(height: 12),
            _buildOtherComponentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Современные кнопки с иерархией
        const Text(
          'Primary кнопки',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Основное действие',
              type: ButtonType.primary,
              onPressed: () => _showMessage('Нажата primary кнопка'),
            ),
            ModernButton(
              text: 'С иконкой',
              type: ButtonType.primary,
              onPressed: () => _showMessage('Нажата кнопка с иконкой'),
              icon: Icons.star,
            ),
            ModernButton(
              text: 'Загрузка...',
              type: ButtonType.primary,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _simulateLoading,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Secondary кнопки',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Второстепенное',
              type: ButtonType.secondary,
              onPressed: () => _showMessage('Нажата secondary кнопка'),
            ),
            ModernButton(
              text: 'С иконкой',
              type: ButtonType.secondary,
              onPressed: () => _showMessage('Secondary с иконкой'),
              icon: Icons.edit,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Tertiary кнопки',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Вспомогательная',
              type: ButtonType.tertiary,
              onPressed: () => _showMessage('Нажата tertiary кнопка'),
            ),
            ModernButton(
              text: 'Отмена',
              type: ButtonType.tertiary,
              onPressed: () => _showMessage('Действие отменено'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Статусные кнопки',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Успех',
              type: ButtonType.success,
              onPressed: () => _showMessage('Операция выполнена успешно'),
            ),
            ModernButton(
              text: 'Предупреждение',
              type: ButtonType.warning,
              onPressed: () => _showMessage('Внимание'),
            ),
            ModernButton(
              text: 'Удалить',
              type: ButtonType.danger,
              onPressed: () => _showMessage('Опасное действие'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Переключатели',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernToggle(
              text: 'Активный',
              isSelected: _isToggleSelected,
              onTap: () => setState(() => _isToggleSelected = !_isToggleSelected),
            ),
            ModernToggle(
              text: 'Переключатель 2',
              isSelected: !_isToggleSelected,
              onTap: () => setState(() => _isToggleSelected = !_isToggleSelected),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const SizedBox(height: 16),
        
        const Text(
          'Иконковые кнопки',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: '',
              type: ButtonType.tertiary,
              icon: Icons.favorite,
              onPressed: () => _showMessage('Нажата кнопка "Избранное"'),
            ),
            ModernButton(
              text: '',
              type: ButtonType.tertiary,
              icon: Icons.share,
              onPressed: () => _showMessage('Нажата кнопка "Поделиться"'),
            ),
            ModernButton(
              text: '',
              type: ButtonType.tertiary,
              icon: Icons.download,
              onPressed: () => _showMessage('Нажата кнопка "Скачать"'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Tertiary кнопки с иконками',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Избранное',
              type: ButtonType.tertiary,
              icon: Icons.favorite,
              onPressed: () => _showMessage('Нажата кнопка "Избранное"'),
            ),
            ModernButton(
              text: 'Поделиться',
              type: ButtonType.tertiary,
              icon: Icons.share,
              onPressed: () => _showMessage('Нажата кнопка "Поделиться"'),
            ),
            ModernButton(
              text: 'Скачать',
              type: ButtonType.tertiary,
              icon: Icons.download,
              onPressed: () => _showMessage('Нажата кнопка "Скачать"'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Базовое поле ввода
        CustomTextField(
          label: 'Обычное поле ввода',
          hint: 'Введите текст...',
          controller: _textController,
          onChanged: (value) => _showMessage('Текст изменен: $value'),
        ),
        
        const SizedBox(height: 16),
        
        // Поле с валидацией
        CustomTextField(
          label: 'Email',
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Поле обязательно для заполнения';
            }
            if (!value.contains('@')) {
              return 'Введите корректный email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Поле пароля
        CustomTextField(
          label: 'Пароль',
          hint: 'Введите пароль',
          obscureText: true,
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Пароль должен содержать минимум 6 символов';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Многострочное поле
        const CustomTextField(
          label: 'Описание',
          hint: 'Введите описание...',
          maxLines: 4,
          maxLength: 200,
          showCounter: true,
        ),
        
        const SizedBox(height: 16),
        
        // Поле поиска
        CustomSearchField(
          hint: 'Поиск компонентов...',
          controller: _searchController,
          onChanged: (value) => _showMessage('Поиск: $value'),
          onClear: () => _showMessage('Поиск очищен'),
        ),
        
        const SizedBox(height: 16),
        
        // Неактивное поле
        const CustomTextField(
          label: 'Неактивное поле',
          hint: 'Это поле неактивно',
          enabled: false,
          initialValue: 'Значение нельзя изменить',
        ),
      ],
    );
  }

  Widget _buildDialogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Диалог подтверждения',
              type: ButtonType.primary,
              onPressed: _showConfirmDialog,
            ),
            ModernButton(
              text: 'Диалог ввода',
              type: ButtonType.primary,
              onPressed: _showInputDialog,
            ),
            ModernButton(
              text: 'Диалог выбора',
              type: ButtonType.primary,
              onPressed: _showChoiceDialog,
            ),
            ModernButton(
              text: 'Диалог загрузки',
              type: ButtonType.primary,
              onPressed: _showLoadingDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тестирование toast уведомлений:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ModernButton(
              text: 'Default Toast',
              type: ButtonType.primary,
              onPressed: () => toast.show(description: 'Это обычное уведомление'),
            ),
            ModernButton(
              text: 'Success Toast',
              type: ButtonType.success,
              onPressed: () => toast.success(description: 'Операция выполнена успешно!'),
            ),
            ModernButton(
              text: 'Warning Toast',
              type: ButtonType.warning,
              onPressed: () => toast.warning(description: 'Внимание! Проверьте данные.'),
            ),
            ModernButton(
              text: 'Error Toast',
              type: ButtonType.danger,
              onPressed: () => toast.error(description: 'Произошла ошибка!'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherComponentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SVG иконки
        Row(
          children: [
            Text(
              'SVG иконки:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              'assets/images/novaspec-logo.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              'assets/images/atlassian-icon.svg',
              width: 32,
              height: 32,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Индикаторы прогресса
        Row(
          children: [
            Text(
              'Индикаторы:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            const SizedBox(
              width: 20,
              height: 20,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Чипсы/теги
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: const Text('Активный'),
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            Chip(
              label: const Text('В работе'),
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
            ),
            Chip(
              label: const Text('Завершен'),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
            ),
          ],
        ),
      ],
    );
  }

  void _showMessage(String message) {
    // Используем toast вместо SnackBar для демонстрации
    toast.show(description: message);
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    _showMessage('Загрузка завершена');
  }

  void _showConfirmDialog() {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Подтверждение действия',
      content: 'Вы уверены, что хотите выполнить это действие?',
      onConfirm: () => _showMessage('Действие подтверждено'),
      onCancel: () => _showMessage('Действие отменено'),
    );
  }

  void _showInputDialog() {
    DialogHelper.showInputDialog(
      context,
      title: 'Введите данные',
      content: 'Пожалуйста, введите ваше имя:',
      hint: 'Имя',
      initialValue: 'Пользователь',
      onConfirm: (value) => _showMessage('Введено: $value'),
    );
  }

  void _showChoiceDialog() {
    final options = [
      const CustomChoiceOption(value: 'option1', title: 'Вариант 1', description: 'Описание первого варианта'),
      const CustomChoiceOption(value: 'option2', title: 'Вариант 2', description: 'Описание второго варианта'),
      const CustomChoiceOption(value: 'option3', title: 'Вариант 3', description: 'Описание третьего варианта'),
    ];

    DialogHelper.showChoiceDialog<String>(
      context,
      title: 'Выберите вариант',
      options: options,
      selectedValue: 'option1',
      onSelected: (value) => _showMessage('Выбрано: $value'),
    );
  }

  void _showLoadingDialog() {
    DialogHelper.showLoadingDialog(
      context,
      title: 'Загрузка',
      content: 'Пожалуйста, подождите...',
    );
    
    // Автоматически закрываем через 2 секунды
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        DialogHelper.hideLoadingDialog(context);
        _showMessage('Загрузка завершена');
      }
    });
  }
}