# TypeScript UI Components Analysis

## Обзор

Проект содержит **49 UI компонентов** в директории `src/components/ui/`, основанных на:
- **Radix UI** - Low-level primitives для доступности
- **Tailwind CSS** - Стилизация
- **class-variance-authority (cva)** - Варианты компонентов
- **Lucide React** - Иконки

## Категории компонентов

### 1. Формы и ввод данных
- **button.tsx** - Кнопки (6 вариантов, 4 размера)
- **input.tsx** - Поля ввода
- **textarea.tsx** - Текстовые области
- **select.tsx** - Выпадающие списки
- **checkbox.tsx** - Чекбоксы
- **radio-group.tsx** - Радиокнопки
- **switch.tsx** - Переключатели
- **label.tsx** - Метки полей
- **form.tsx** - Формы
- **input-otp.tsx** - OTP ввод

### 2. Навигация и меню
- **navigation-menu.tsx** - Навигационное меню
- **menubar.tsx** - Меню бар
- **dropdown-menu.tsx** - Выпадающие меню
- **context-menu.tsx** - Контекстные меню
- **breadcrumb.tsx** - "Хлебные крошки"
- **tabs.tsx** - Табы
- **pagination.tsx** - Пагинация

### 3. Диалоги и окна
- **dialog.tsx** - Модальные окна
- **alert-dialog.tsx** - Диалоги подтверждения
- **drawer.tsx** - Боковые панели
- **sheet.tsx** - Выдвижные панели
- **popover.tsx** - Всплывающие окна

### 4. Уведомления и обратная связь
- **alert.tsx** - Уведомления
- **toast.tsx** - Toast уведомления
- **toaster.tsx** - Контейнер для toast
- **sonner.tsx** - Sonner toast
- **progress.tsx** - Прогресс бары
- **skeleton.tsx** - Скелетоны загрузки
- **loading-widget.tsx** - Индикаторы загрузки

### 5. Отображение данных
- **card.tsx** - Карточки
- **table.tsx** - Таблицы
- **accordion.tsx** - Аккордеоны
- **collapsible.tsx** - Сворачиваемые элементы
- **scroll-area.tsx** - Прокручиваемые области
- **separator.tsx** - Разделители
- **badge.tsx** - Бейджи
- **avatar.tsx** - Аватары

### 6. Интерактивные элементы
- **slider.tsx** - Слайдеры
- **toggle.tsx** - Тогглы
- **toggle-group.tsx** - Группы тогглов
- **resizable.tsx** - Изменяемые размеры
- **command.tsx** - Командная палитра

### 7. Вспомогательные компоненты
- **tooltip.tsx** - Всплывающие подсказки
- **hover-card.tsx** - Карточки при наведении
- **aspect-ratio.tsx** - Соотношение сторон
- **calendar.tsx** - Календари
- **chart.tsx** - Графики
- **carousel.tsx** - Карусели

### 8. Хуки
- **use-toast.ts** - Хук для toast уведомлений

## Детальный анализ ключевых компонентов

### Button компонент
```typescript
// Варианты: default, destructive, outline, secondary, ghost, link
// Размеры: default, sm, lg, icon
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
  }
);
```

### Select компонент
**Особенности:**
- Полностью основан на Radix UI Select
- Поддержка скроллинга (ScrollUpButton/ScrollDownButton)
- Портальный рендеринг контента
- Индикатор выбора (Check иконка)
- Поддержка группировки и разделителей

### Dialog компонент
**Особенности:**
- Композиционная структура (Header, Footer, Title, Description)
- Анимации входа/выхода
- Портальный рендеринг
- Overlay с затемнением
- Кнопка закрытия

### Alert компонент
```typescript
const alertVariants = cva(
  "relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground",
  {
    variants: {
      variant: {
        default: "bg-background text-foreground",
        destructive: "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive",
      },
    },
  }
);
```

### ScrollArea компонент
**Особенности:**
- Кастомные скроллбары
- Вертикальная и горизонтальная ориентация
- Автоматическое определение необходимости скролла
- Corner элемент для пересечения скроллов

## Архитектурные паттерны

### 1. ForwardRef паттерн
Все компоненты используют `React.forwardRef` для передачи ref:
```typescript
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />;
  }
);
```

### 2. CVA для вариантов
`class-variance-authority` используется для управления вариантами:
```typescript
const buttonVariants = cva(baseClasses, {
  variants: {
    variant: { /* варианты */ },
    size: { /* размеры */ }
  },
  defaultVariants: { /* значения по умолчанию */ }
});
```

### 3. Композиция компонентов
Многие компоненты имеют составную структуру:
```typescript
export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent };
export { Dialog, DialogPortal, DialogOverlay, DialogClose, DialogTrigger, DialogContent, DialogHeader, DialogFooter, DialogTitle, DialogDescription };
```

### 4. Radix UI интеграция
Большинство компонентов основаны на Radix UI primitives:
- **Accessibility** - ARIA атрибуты
- **Keyboard navigation** - Навигация клавиатурой
- **Focus management** - Управление фокусом
- **Screen reader support** - Поддержка скринридеров

### 5. Утилита cn()
Используется для объединения классов:
```typescript
import { cn } from "@/lib/utils";

className={cn(
  "базовые классы",
  condition && "условные классы",
  className // пропсы для переопределения
)}
```

## Стилевая система

### 1. Tailwind CSS конфигурация
- **Цветовая схема:** CSS переменные (primary, secondary, muted, accent, destructive)
- **Типографика:** text-sm, text-base, text-lg и т.д.
- **Отступы:** p-1, p-2, p-3, p-4, p-6, p-8
- **Радиусы:** rounded-md, rounded-lg, rounded-full
- **Тени:** shadow-sm, shadow-md, shadow-lg

### 2. CSS переменные
```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  /* ... */
}
```

### 3. Темная тема
Поддержка через `dark:` префиксы:
```typescript
destructive: "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive"
```

## Анимации и переходы

### 1. CSS transitions
```typescript
"transition-colors focus-visible:outline-none focus-visible:ring-2"
"hover:bg-accent hover:text-accent-foreground"
```

### 2. Radix UI анимации
```typescript
"data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95"
```

### 3. Tailwind анимации
- `animate-in` / `animate-out`
- `fade-in-0` / `fade-out-0`
- `zoom-in-95` / `zoom-out-95`
- `slide-in-from-*` / `slide-out-to-*`

## Типизация

### 1. TypeScript интерфейсы
```typescript
export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}
```

### 2. Generic типы
```typescript
const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>
```

### 3. VariantProps
```typescript
import { type VariantProps } from "class-variance-authority";
```

## Иконки

### Lucide React
Основная библиотека иконок:
- **Размеры:** w-3 h-3, w-4 h-4, w-5 h-5, w-6 h-6
- **Цвета:** text-foreground, text-muted-foreground, text-primary
- **Популярные:** Check, X, ChevronDown, ChevronUp, Menu, Search

### SVG ассеты
- `@/assets/novaspec-logo.svg`
- `@/assets/atlassian-icon.svg`

## Интеграции

### Внешние библиотеки
```json
{
  "@radix-ui/react-*": "UI primitives",
  "class-variance-authority": "Варианты компонентов",
  "lucide-react": "Иконки",
  "sonner": "Toast уведомления",
  "cmdk": "Командная палитра",
  "swagger-ui-react": "Swagger UI"
}
```

### Паттерны импорта
```typescript
import * as React from "react";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { X } from "lucide-react";
```

## Потенциальные сложности для Flutter миграции

### 1. Система вариантов
- **React:** CVA + Tailwind классы
- **Flutter:** Widget параметры + ThemeData

### 2. Композиция
- **React:** Множественные экспорты компонентов
- **Flutter:** Widget классы с параметрами

### 3. Анимации
- **React:** CSS transitions + Radix анимации
- **Flutter:** AnimationController + Tween

### 4. Доступность
- **React:** Radix UI (автоматически)
- **Flutter:** Semantics widget (ручная настройка)

### 5. Стили
- **React:** Tailwind CSS классы
- **Flutter:** TextStyle, Decoration, ThemeData

### 6. Портальный рендеринг
- **React:** Portal компоненты
- **Flutter:** Overlay, Stack

## Рекомендации по миграции

### 1. Создать базовые виджеты
```dart
class CustomButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Widget? child;
  
  // Реализация вариантов через ThemeData
}
```

### 2. Использовать Material Design 3
- Как эквивалент shadcn/ui
- Встроенная доступность
- Темная тема из коробки

### 3. Композиция виджетов
```dart
class CustomCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? actions;
  final Widget child;
  
  // Аналог Card + CardHeader + CardContent
}
```

### 4. Анимации
```dart
class AnimatedDialog extends StatefulWidget {
  // Использование AnimationController
  // Аналог Radix анимаций
}
```

### 5. Система тем
```dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      // Кастомные компоненты темы
    );
  }
}
```