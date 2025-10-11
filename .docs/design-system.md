# Дизайн-система NovaSpec

## 1. Введение

Дизайн-система NovaSpec создана для обеспечения визуального единства и согласованности пользовательского интерфейса десктопного приложения на Flutter. Система базируется на современных принципах материального дизайна, адаптированных для десктопных платформ, и полностью соответствует TypeScript референсу.

### 1.1. Философия дизайна

- **Ясность и читаемость** — интерфейс должен быть понятным и не отвлекать от работы
- **Профессиональность** — инструмент для работы, а не развлечения
- **Отзывчивость** — все элементы должны мгновенно реагировать на действия пользователя
- **Консистентность** — единые паттерны взаимодействия во всем приложении
- **Доступность** — поддержка клавиатурной навигации, tooltips, контрастность

---

## 2. Цветовая палитра

### 2.1. Основные цвета

Все цвета определены в формате HSL (Hue, Saturation, Lightness) для удобства работы с темами.

#### Светлая тема (Light Theme)

```dart
class NsColorsLight {
  // Основные цвета
  static const Color background = Color.fromRGBO(255, 255, 255, 1.0);      // hsl(0, 0%, 100%)
  static const Color foreground = Color.fromRGBO(26, 26, 26, 1.0);         // hsl(0, 0%, 10%)

  // Основной цвет (MTS Granat - гранатово-красный)
  static const Color primary = Color.fromRGBO(168, 7, 50, 1.0);            // hsl(354, 92%, 34%)
  static const Color primaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Вторичный цвет
  static const Color secondary = Color.fromRGBO(245, 245, 245, 1.0);       // hsl(0, 0%, 96%)
  static const Color secondaryForeground = Color.fromRGBO(26, 26, 26, 1.0); // hsl(0, 0%, 10%)

  // Приглушенные цвета (muted)
  static const Color muted = Color.fromRGBO(245, 245, 245, 1.0);           // hsl(0, 0%, 96%)
  static const Color mutedForeground = Color.fromRGBO(115, 115, 115, 1.0); // hsl(0, 0%, 45%)

  // Акцентный цвет
  static const Color accent = Color.fromRGBO(168, 7, 50, 1.0);             // hsl(354, 92%, 34%)
  static const Color accentForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Деструктивный (ошибки, удаление)
  static const Color destructive = Color.fromRGBO(239, 68, 68, 1.0);       // hsl(0, 84%, 60%)
  static const Color destructiveForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Границы и обводки
  static const Color border = Color.fromRGBO(224, 224, 224, 1.0);          // hsl(0, 0%, 88%)
  static const Color input = Color.fromRGBO(224, 224, 224, 1.0);           // hsl(0, 0%, 88%)
  static const Color ring = Color.fromRGBO(168, 7, 50, 1.0);               // hsl(354, 92%, 34%)

  // Карточки и поповеры
  static const Color card = Color.fromRGBO(255, 255, 255, 1.0);            // hsl(0, 0%, 100%)
  static const Color cardForeground = Color.fromRGBO(26, 26, 26, 1.0);     // hsl(0, 0%, 10%)
  static const Color popover = Color.fromRGBO(255, 255, 255, 1.0);         // hsl(0, 0%, 100%)
  static const Color popoverForeground = Color.fromRGBO(26, 26, 26, 1.0);  // hsl(0, 0%, 10%)

  // IDE-специфичные цвета
  static const Color panel = Color.fromRGBO(250, 250, 250, 1.0);           // hsl(0, 0%, 98%)
  static const Color editor = Color.fromRGBO(255, 255, 255, 1.0);          // hsl(0, 0%, 100%)
  static const Color sidebar = Color.fromRGBO(247, 247, 247, 1.0);         // hsl(0, 0%, 97%)
  static const Color statusbar = Color.fromRGBO(242, 242, 242, 1.0);       // hsl(0, 0%, 95%)
  static const Color hover = Color.fromRGBO(237, 237, 237, 1.0);           // hsl(0, 0%, 93%)

  // Индикаторы состояния
  static const Color indicatorActive = Color.fromRGBO(168, 7, 50, 1.0);    // hsl(354, 92%, 34%)
  static const Color indicatorInactive = Color.fromRGBO(153, 153, 153, 1.0); // hsl(0, 0%, 60%)
}
```

#### Темная тема (Dark Theme)

```dart
class NsColorsDark {
  // Основные цвета
  static const Color background = Color.fromRGBO(28, 28, 28, 1.0);         // hsl(0, 0%, 11%)
  static const Color foreground = Color.fromRGBO(250, 250, 250, 1.0);      // hsl(0, 0%, 98%)

  // Основной цвет (MTS Granat - светлее для темной темы)
  static const Color primary = Color.fromRGBO(235, 69, 117, 1.0);          // hsl(354, 92%, 55%)
  static const Color primaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Вторичный цвет
  static const Color secondary = Color.fromRGBO(38, 38, 38, 1.0);          // hsl(0, 0%, 15%)
  static const Color secondaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Приглушенные цвета (muted)
  static const Color muted = Color.fromRGBO(38, 38, 38, 1.0);              // hsl(0, 0%, 15%)
  static const Color mutedForeground = Color.fromRGBO(166, 166, 166, 1.0); // hsl(0, 0%, 65%)

  // Акцентный цвет
  static const Color accent = Color.fromRGBO(235, 69, 117, 1.0);           // hsl(354, 92%, 55%)
  static const Color accentForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Деструктивный
  static const Color destructive = Color.fromRGBO(153, 27, 27, 1.0);       // hsl(0, 63%, 31%)
  static const Color destructiveForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Границы и обводки
  static const Color border = Color.fromRGBO(46, 46, 46, 1.0);             // hsl(0, 0%, 18%)
  static const Color input = Color.fromRGBO(46, 46, 46, 1.0);              // hsl(0, 0%, 18%)
  static const Color ring = Color.fromRGBO(235, 69, 117, 1.0);             // hsl(354, 92%, 55%)

  // Карточки и поповеры
  static const Color card = Color.fromRGBO(28, 28, 28, 1.0);               // hsl(0, 0%, 11%)
  static const Color cardForeground = Color.fromRGBO(250, 250, 250, 1.0);  // hsl(0, 0%, 98%)
  static const Color popover = Color.fromRGBO(28, 28, 28, 1.0);            // hsl(0, 0%, 11%)
  static const Color popoverForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // IDE-специфичные цвета
  static const Color panel = Color.fromRGBO(20, 20, 20, 1.0);              // hsl(0, 0%, 8%)
  static const Color editor = Color.fromRGBO(28, 28, 28, 1.0);             // hsl(0, 0%, 11%)
  static const Color sidebar = Color.fromRGBO(23, 23, 23, 1.0);            // hsl(0, 0%, 9%)
  static const Color statusbar = Color.fromRGBO(18, 18, 18, 1.0);          // hsl(0, 0%, 7%)
  static const Color hover = Color.fromRGBO(41, 41, 41, 1.0);              // hsl(0, 0%, 16%)

  // Индикаторы состояния
  static const Color indicatorActive = Color.fromRGBO(235, 69, 117, 1.0);  // hsl(354, 92%, 55%)
  static const Color indicatorInactive = Color.fromRGBO(115, 115, 115, 1.0); // hsl(0, 0%, 45%)
}
```

### 2.2. Семантические цвета

```dart
class NsSemanticColors {
  // Успех
  static const Color successLight = Color.fromRGBO(34, 197, 94, 1.0);      // Зеленый
  static const Color successDark = Color.fromRGBO(74, 222, 128, 1.0);

  // Предупреждение
  static const Color warningLight = Color.fromRGBO(234, 179, 8, 1.0);      // Желтый
  static const Color warningDark = Color.fromRGBO(250, 204, 21, 1.0);

  // Информация
  static const Color infoLight = Color.fromRGBO(59, 130, 246, 1.0);        // Синий
  static const Color infoDark = Color.fromRGBO(96, 165, 250, 1.0);

  // Ошибка
  static const Color errorLight = Color.fromRGBO(239, 68, 68, 1.0);        // Красный
  static const Color errorDark = Color.fromRGBO(248, 113, 113, 1.0);
}
```

### 2.3. Цвета для типов файлов

```dart
class NsFileColors {
  static const Color markdown = Color.fromRGBO(59, 130, 246, 1.0);         // Синий
  static const Color html = Color.fromRGBO(249, 115, 22, 1.0);             // Оранжевый
  static const Color json = Color.fromRGBO(234, 179, 8, 1.0);              // Желтый
  static const Color xml = Color.fromRGBO(34, 197, 94, 1.0);               // Зеленый
  static const Color yaml = Color.fromRGBO(168, 85, 247, 1.0);             // Фиолетовый
  static const Color audio = Color.fromRGBO(236, 72, 153, 1.0);            // Розовый
  static const Color audioWav = Color.fromRGBO(6, 182, 212, 1.0);          // Голубой
  static const Color defaultFile = Color.fromRGBO(115, 115, 115, 1.0);     // Серый
}
```

---

## 3. Типографика

### 3.1. Шрифты

**Основной шрифт:** `Inter` (Google Fonts)
**Запасные шрифты:** `SF Pro` (macOS), `Segoe UI` (Windows), `Roboto`, `system-ui`, `sans-serif`

**Моноширинный шрифт (для редактора кода):** `JetBrains Mono`, `Fira Code`, `Consolas`, `monospace`

### 3.2. Размеры текста

```dart
class NsTextSizes {
  // Заголовки
  static const double h1 = 32.0;        // 2rem
  static const double h2 = 24.0;        // 1.5rem
  static const double h3 = 20.0;        // 1.25rem
  static const double h4 = 18.0;        // 1.125rem

  // Основной текст
  static const double bodyLarge = 16.0;  // 1rem
  static const double bodyMedium = 14.0; // 0.875rem
  static const double bodySmall = 12.0;  // 0.75rem

  // Дополнительный текст
  static const double caption = 11.0;    // 0.6875rem
  static const double overline = 10.0;   // 0.625rem
}
```

### 3.3. Высота строки

```dart
class NsLineHeights {
  static const double tight = 1.2;
  static const double normal = 1.5;
  static const double relaxed = 1.75;
  static const double loose = 2.0;
}
```

### 3.4. Вес шрифта

```dart
class NsFontWeights {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
```

### 3.5. TextStyle конфигурации

```dart
class NsTextStyles {
  // Заголовки
  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.h1,
    fontWeight: NsFontWeights.bold,
    height: NsLineHeights.tight,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.h2,
    fontWeight: NsFontWeights.semiBold,
    height: NsLineHeights.tight,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.h3,
    fontWeight: NsFontWeights.semiBold,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle h4(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.h4,
    fontWeight: NsFontWeights.medium,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Основной текст
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.bodyLarge,
    fontWeight: NsFontWeights.regular,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.bodyMedium,
    fontWeight: NsFontWeights.regular,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.bodySmall,
    fontWeight: NsFontWeights.regular,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Специальные
  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.caption,
    fontWeight: NsFontWeights.regular,
    height: NsLineHeights.normal,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.bodyMedium,
    fontWeight: NsFontWeights.medium,
    height: 1.0,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onPrimary,
  );

  // Моноширинный (для кода)
  static TextStyle code(BuildContext context) => TextStyle(
    fontSize: NsTextSizes.bodyMedium,
    fontWeight: NsFontWeights.regular,
    fontFamily: 'JetBrainsMono',
    height: NsLineHeights.relaxed,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
```

---

## 4. Отступы и spacing

### 4.1. Система отступов

```dart
class NsSpacing {
  // Базовая единица: 4px
  static const double unit = 4.0;

  // Отступы
  static const double xxs = 2.0;   // 0.5 unit
  static const double xs = 4.0;    // 1 unit
  static const double sm = 8.0;    // 2 units
  static const double md = 12.0;   // 3 units
  static const double lg = 16.0;   // 4 units
  static const double xl = 24.0;   // 6 units
  static const double xxl = 32.0;  // 8 units
  static const double xxxl = 48.0; // 12 units

  // Специфичные отступы для компонентов
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double inputPaddingHorizontal = 12.0;
  static const double inputPaddingVertical = 10.0;
  static const double cardPadding = 16.0;
  static const double dialogPadding = 24.0;
  static const double sectionSpacing = 24.0;
}
```

### 4.2. EdgeInsets пресеты

```dart
class NsPadding {
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets xxs = EdgeInsets.all(NsSpacing.xxs);
  static const EdgeInsets xs = EdgeInsets.all(NsSpacing.xs);
  static const EdgeInsets sm = EdgeInsets.all(NsSpacing.sm);
  static const EdgeInsets md = EdgeInsets.all(NsSpacing.md);
  static const EdgeInsets lg = EdgeInsets.all(NsSpacing.lg);
  static const EdgeInsets xl = EdgeInsets.all(NsSpacing.xl);
  static const EdgeInsets xxl = EdgeInsets.all(NsSpacing.xxl);

  // Горизонтальные
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: NsSpacing.xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: NsSpacing.sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: NsSpacing.md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: NsSpacing.lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: NsSpacing.xl);

  // Вертикальные
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: NsSpacing.xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: NsSpacing.sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: NsSpacing.md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: NsSpacing.lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: NsSpacing.xl);
}
```

---

## 5. Скругления (Border Radius)

### 5.1. Значения радиусов

```dart
class NsBorderRadius {
  // Базовое значение: 10px (0.625rem)
  static const double base = 10.0;

  static const double none = 0.0;
  static const double sm = 6.0;    // base - 4px
  static const double md = 8.0;    // base - 2px
  static const double lg = 10.0;   // base
  static const double xl = 12.0;   // base + 2px
  static const double xxl = 16.0;  // base + 6px
  static const double full = 9999.0; // Полностью скругленный
}
```

### 5.2. BorderRadius пресеты

```dart
class NsRadius {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius sm = BorderRadius.all(Radius.circular(NsBorderRadius.sm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(NsBorderRadius.md));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(NsBorderRadius.lg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(NsBorderRadius.xl));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(NsBorderRadius.xxl));
  static const BorderRadius full = BorderRadius.all(Radius.circular(NsBorderRadius.full));

  // Специфичные для компонентов
  static const BorderRadius button = lg;
  static const BorderRadius input = lg;
  static const BorderRadius card = xl;
  static const BorderRadius dialog = xxl;
}
```

---

## 6. Тени (Elevation & Shadows)

### 6.1. Box Shadow конфигурации

```dart
class NsShadows {
  // Нет тени
  static const List<BoxShadow> none = [];

  // Малая тень (кнопки, карточки)
  static List<BoxShadow> sm(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  // Средняя тень (модальные окна, поповеры)
  static List<BoxShadow> md(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  // Большая тень (диалоги)
  static List<BoxShadow> lg(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // Очень большая тень (оверлеи)
  static List<BoxShadow> xl(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
```

---

## 7. Компоненты

### 7.1. NsButton

Универсальная кнопка с различными вариантами оформления.

**Варианты (Variants):**
- `primary` — основная кнопка с заливкой primary цветом
- `secondary` — вторичная кнопка с заливкой secondary цветом
- `outline` — кнопка с обводкой
- `ghost` — кнопка без фона (прозрачная)
- `destructive` — кнопка для деструктивных действий

**Размеры (Sizes):**
- `small` — 32px высота, 12px vertical padding, 16px horizontal padding
- `medium` — 40px высота, 12px vertical padding, 24px horizontal padding
- `large` — 48px высота, 16px vertical padding, 32px horizontal padding
- `icon` — квадратная 40x40px (только иконка)

**Параметры:**
```dart
class NsButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final NsButtonVariant variant;
  final NsButtonSize size;
  final bool fullWidth;
  final bool disabled;
  final Widget? child;

  const NsButton({
    Key? key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = NsButtonVariant.primary,
    this.size = NsButtonSize.medium,
    this.fullWidth = false,
    this.disabled = false,
    this.child,
  }) : super(key: key);
}

enum NsButtonVariant { primary, secondary, outline, ghost, destructive }
enum NsButtonSize { small, medium, large, icon }
```

**Визуальные характеристики:**
- Border radius: `lg` (10px)
- Font weight: `medium` (500)
- Transition: 150ms ease-out (для hover/press состояний)
- Disabled opacity: 0.5

**Hover состояния:**
- `primary`: затемнение на 10%
- `secondary`: затемнение на 5%
- `outline`: заливка muted цветом
- `ghost`: заливка hover цветом

---

### 7.2. NsTextField

Поле ввода текста.

**Параметры:**
```dart
class NsTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const NsTextField({
    Key? key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Border: 1px solid `border` цвет
- Border radius: `lg` (10px)
- Padding: 10px vertical, 12px horizontal
- Font size: `bodyMedium` (14px)
- Height (single line): 40px

**Состояния:**
- Default: border цвет
- Hover: затемнение border на 10%
- Focus: border цвет = `primary`, ring (outline) 2px
- Error: border цвет = `destructive`
- Disabled: opacity 0.5

---

### 7.3. NsCard

Контейнер для группировки контента.

**Параметры:**
```dart
class NsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool hoverable;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const NsCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.hoverable = false,
    this.backgroundColor,
    this.shadows,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Background: `card` цвет
- Border: 1px solid `border`
- Border radius: `xl` (12px)
- Padding: `lg` (16px) по умолчанию
- Shadow: `sm` (опционально)

**Hover (если hoverable):**
- Background: `hover` цвет

---

### 7.4. NsDialog

Модальное диалоговое окно.

**Параметры:**
```dart
class NsDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final List<Widget>? actions;
  final bool dismissible;
  final double? maxWidth;

  const NsDialog({
    Key? key,
    this.title,
    this.description,
    this.content,
    this.actions,
    this.dismissible = true,
    this.maxWidth,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Background: `card` цвет
- Border radius: `xxl` (16px)
- Padding: `xl` (24px)
- Max width: 500px (по умолчанию)
- Shadow: `xl`
- Overlay: черный с opacity 0.5

**Структура:**
- Header (title + description)
- Content
- Footer (actions)

---

### 7.5. NsSelect (Dropdown)

Выпадающий список.

**Параметры:**
```dart
class NsSelect<T> extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final T? value;
  final List<NsSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const NsSelect({
    Key? key,
    this.label,
    this.placeholder,
    this.value,
    required this.options,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);
}

class NsSelectOption<T> {
  final T value;
  final String label;
  final Widget? icon;

  const NsSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
```

**Визуальные характеристики:**
- Аналогично NsTextField
- Dropdown menu: background `popover`, border radius `md`
- Max height: 320px (с прокруткой)

---

### 7.6. NsSwitch

Переключатель (toggle).

**Параметры:**
```dart
class NsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const NsSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Width: 44px, Height: 24px
- Border radius: `full`
- Thumb (круг): 20px диаметр
- Active color: `primary`
- Inactive color: `input`
- Transition: 150ms

---

### 7.7. NsTooltip

Всплывающая подсказка.

**Параметры:**
```dart
class NsTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipPosition position;

  const NsTooltip({
    Key? key,
    required this.message,
    required this.child,
    this.position = TooltipPosition.top,
  }) : super(key: key);
}

enum TooltipPosition { top, bottom, left, right }
```

**Визуальные характеристики:**
- Background: `popover` с opacity 0.95
- Foreground: `popoverForeground`
- Padding: 6px vertical, 8px horizontal
- Border radius: `md` (8px)
- Font size: `bodySmall` (12px)
- Delay: 500ms

---

### 7.8. NsMenuItem

Элемент меню (для TopBar, контекстных меню).

**Параметры:**
```dart
class NsMenuItem extends StatelessWidget {
  final String label;
  final Widget? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool disabled;
  final bool destructive;

  const NsMenuItem({
    Key? key,
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.disabled = false,
    this.destructive = false,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Height: 36px
- Padding: 8px horizontal
- Font size: `bodyMedium` (14px)
- Hover: background `hover`
- Shortcut: muted foreground, align right

---

### 7.9. NsTab (TabBar)

Вкладки.

**Параметры:**
```dart
class NsTabBar extends StatelessWidget {
  final List<NsTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const NsTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
  }) : super(key: key);
}

class NsTab {
  final String label;
  final Widget? icon;
  final bool closable;

  const NsTab({
    required this.label,
    this.icon,
    this.closable = false,
  });
}
```

**Визуальные характеристики:**
- Height: 40px
- Padding: 12px horizontal
- Border radius top: `lg`
- Active: background `editor`, foreground `foreground`
- Inactive: background `muted`, foreground `mutedForeground`
- Hover (inactive): background осветление/затемнение

---

### 7.10. NsScrollArea

Область прокрутки с кастомным скроллбаром.

**Параметры:**
```dart
class NsScrollArea extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final Axis scrollDirection;

  const NsScrollArea({
    Key? key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);
}
```

**Визуальные характеристики:**
- Scrollbar width: 8px
- Scrollbar color: `mutedForeground` с opacity 0.3
- Scrollbar hover: opacity 0.5
- Border radius: `full`

---

## 8. Иконки

### 8.1. Библиотека иконок

Использовать пакет `lucide_icons` (аналог Lucide React).

Если иконка отсутствует в `lucide_icons`, использовать `Icons.*` из Material Icons.

### 8.2. Размеры иконок

```dart
class NsIconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### 8.3. Цвета иконок

Иконки наследуют цвет от родителя или используют семантические цвета:
- Primary действия: `primary`
- Деструктивные действия: `destructive`
- Нейтральные: `foreground`
- Неактивные: `mutedForeground`

---

## 9. Анимации и переходы

### 9.1. Длительности

```dart
class NsDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
```

### 9.2. Кривые

```dart
class NsCurves {
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}
```

### 9.3. Применение

- **Hover состояния:** fast (150ms), easeOut
- **Dialog появление:** normal (250ms), easeInOut
- **Drawer/Sidebar:** normal (250ms), easeOut
- **Accordion:** fast (150ms), easeOut
- **Ripple эффект:** fast (150ms)

---

## 10. Responsive поведение

### 10.1. Breakpoints

```dart
class NsBreakpoints {
  static const double mobile = 640.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double wide = 1280.0;
}
```

### 10.2. Адаптивное поведение

**FileExplorer:**
- Desktop (>1024px): ширина 256px
- Tablet (<1024px): ширина 200px, сворачивается при необходимости
- Mobile (<768px): overlay drawer

**AIAssistant:**
- Desktop (>1024px): ширина 384px
- Tablet (<1024px): ширина 320px, сворачивается при необходимости
- Mobile (<768px): overlay drawer

**SpecPreview:**
- Адаптивная ширина (flex: 1)
- Максимальная ширина контента для markdown: 896px (56rem)

---

## 11. Accessibility (Доступность)

### 11.1. Клавиатурная навигация

- Tab/Shift+Tab: навигация между элементами
- Enter/Space: активация кнопок, чекбоксов, переключателей
- Escape: закрытие модальных окон, меню
- Arrow keys: навигация в списках, меню, табах

### 11.2. Screen readers

- Все интерактивные элементы должны иметь `Semantics`
- Label для полей ввода
- Описание для иконок-кнопок

### 11.3. Контрастность

Минимальные требования WCAG 2.1 AA:
- Нормальный текст: контраст 4.5:1
- Большой текст (>18px): контраст 3:1
- UI элементы: контраст 3:1

---

## 12. Темизация (ThemeData)

### 12.1. Светлая тема

```dart
ThemeData nsLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Цветовая схема
    colorScheme: ColorScheme.light(
      primary: NsColorsLight.primary,
      onPrimary: NsColorsLight.primaryForeground,
      secondary: NsColorsLight.secondary,
      onSecondary: NsColorsLight.secondaryForeground,
      error: NsColorsLight.destructive,
      onError: NsColorsLight.destructiveForeground,
      surface: NsColorsLight.background,
      onSurface: NsColorsLight.foreground,
    ),

    // Типографика
    fontFamily: 'Inter',
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: NsTextSizes.h1, fontWeight: NsFontWeights.bold),
      displayMedium: TextStyle(fontSize: NsTextSizes.h2, fontWeight: NsFontWeights.semiBold),
      displaySmall: TextStyle(fontSize: NsTextSizes.h3, fontWeight: NsFontWeights.semiBold),
      headlineMedium: TextStyle(fontSize: NsTextSizes.h4, fontWeight: NsFontWeights.medium),
      bodyLarge: TextStyle(fontSize: NsTextSizes.bodyLarge, fontWeight: NsFontWeights.regular),
      bodyMedium: TextStyle(fontSize: NsTextSizes.bodyMedium, fontWeight: NsFontWeights.regular),
      bodySmall: TextStyle(fontSize: NsTextSizes.bodySmall, fontWeight: NsFontWeights.regular),
      labelSmall: TextStyle(fontSize: NsTextSizes.caption, fontWeight: NsFontWeights.regular),
    ),

    // Формы и inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: NsRadius.input,
        borderSide: BorderSide(color: NsColorsLight.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: NsRadius.input,
        borderSide: BorderSide(color: NsColorsLight.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: NsRadius.input,
        borderSide: BorderSide(color: NsColorsLight.ring, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: NsRadius.input,
        borderSide: BorderSide(color: NsColorsLight.destructive),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: NsSpacing.inputPaddingHorizontal,
        vertical: NsSpacing.inputPaddingVertical,
      ),
    ),

    // Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NsColorsLight.primary,
        foregroundColor: NsColorsLight.primaryForeground,
        padding: EdgeInsets.symmetric(
          horizontal: NsSpacing.buttonPaddingHorizontal,
          vertical: NsSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: NsRadius.button),
        textStyle: TextStyle(
          fontSize: NsTextSizes.bodyMedium,
          fontWeight: NsFontWeights.medium,
        ),
      ),
    ),

    // Карточки
    cardTheme: CardTheme(
      color: NsColorsLight.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: NsRadius.card,
        side: BorderSide(color: NsColorsLight.border),
      ),
    ),

    // Диалоги
    dialogTheme: DialogTheme(
      backgroundColor: NsColorsLight.card,
      shape: RoundedRectangleBorder(borderRadius: NsRadius.dialog),
    ),
  );
}
```

### 12.2. Темная тема

Аналогично светлой теме, но с использованием `NsColorsDark`.

---

## 13. Специфичные для IDE компоненты

### 13.1. Цвета панелей

```dart
class NsIdeColors {
  // Light
  static const Color panelLight = NsColorsLight.panel;
  static const Color editorLight = NsColorsLight.editor;
  static const Color sidebarLight = NsColorsLight.sidebar;
  static const Color statusbarLight = NsColorsLight.statusbar;
  static const Color hoverLight = NsColorsLight.hover;

  // Dark
  static const Color panelDark = NsColorsDark.panel;
  static const Color editorDark = NsColorsDark.editor;
  static const Color sidebarDark = NsColorsDark.sidebar;
  static const Color statusbarDark = NsColorsDark.statusbar;
  static const Color hoverDark = NsColorsDark.hover;
}
```

### 13.2. Высоты элементов

```dart
class NsHeights {
  static const double topBar = 48.0;
  static const double statusBar = 24.0;
  static const double tabBar = 40.0;
  static const double menuItem = 36.0;
}
```

---

## 14. Примеры использования

### 14.1. Кнопка

```dart
NsButton(
  text: 'Сохранить',
  icon: LucideIcons.save,
  onPressed: () => print('Saved'),
  variant: NsButtonVariant.primary,
  size: NsButtonSize.medium,
)
```

### 14.2. Поле ввода

```dart
NsTextField(
  label: 'Email',
  placeholder: 'example@email.com',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(LucideIcons.mail),
)
```

### 14.3. Карточка

```dart
NsCard(
  padding: NsPadding.lg,
  hoverable: true,
  onTap: () => print('Card tapped'),
  child: Column(
    children: [
      Text('Заголовок', style: NsTextStyles.h3(context)),
      SizedBox(height: NsSpacing.md),
      Text('Описание', style: NsTextStyles.bodyMedium(context)),
    ],
  ),
)
```

### 14.4. Диалог

```dart
showDialog(
  context: context,
  builder: (context) => NsDialog(
    title: 'Подтверждение',
    description: 'Вы уверены, что хотите удалить этот элемент?',
    actions: [
      NsButton(
        text: 'Отмена',
        variant: NsButtonVariant.outline,
        onPressed: () => Navigator.pop(context),
      ),
      NsButton(
        text: 'Удалить',
        variant: NsButtonVariant.destructive,
        onPressed: () {
          // Удаление
          Navigator.pop(context);
        },
      ),
    ],
  ),
);
```

---

## 15. Контрольный список реализации

### Этап 1: Цвета и типографика
- [ ] Создать `ns_colors_light.dart` и `ns_colors_dark.dart`
- [ ] Создать `ns_text_styles.dart`
- [ ] Настроить шрифты (Inter, JetBrains Mono)

### Этап 2: Spacing и layout
- [ ] Создать `ns_spacing.dart`
- [ ] Создать `ns_border_radius.dart`
- [ ] Создать `ns_shadows.dart`

### Этап 3: Базовые компоненты
- [ ] Реализовать `NsButton`
- [ ] Реализовать `NsTextField`
- [ ] Реализовать `NsCard`
- [ ] Реализовать `NsDialog`

### Этап 4: Дополнительные компоненты
- [ ] Реализовать `NsSelect`
- [ ] Реализовать `NsSwitch`
- [ ] Реализовать `NsTooltip`
- [ ] Реализовать `NsMenuItem`
- [ ] Реализовать `NsTabBar`
- [ ] Реализовать `NsScrollArea`

### Этап 5: Темизация
- [ ] Создать `ns_theme.dart` с `nsLightTheme()` и `nsDarkTheme()`
- [ ] Интегрировать в `MaterialApp`
- [ ] Тестировать переключение тем

### Этап 6: Иконки
- [ ] Добавить зависимость `lucide_icons`
- [ ] Создать маппинг для файловых иконок

### Этап 7: Доступность
- [ ] Проверить клавиатурную навигацию
- [ ] Добавить семантики для screen readers
- [ ] Проверить контрастность цветов

---

## 16. Заключение

Данная дизайн-система обеспечивает полное визуальное и функциональное соответствие TypeScript референсу, адаптированное для Flutter-приложения. Все компоненты спроектированы с учетом:

- Переиспользуемости и расширяемости
- Производительности на десктопных платформах
- Поддержки светлой и темной тем
- Доступности и usability
- Единого стиля кодирования согласно Effective Dart

Система готова к использованию при разработке приложения NovaSpec.

---

**Версия:** 1.0
**Дата создания:** 2025-01-XX
**Автор:** Claude (AI-ассистент)
