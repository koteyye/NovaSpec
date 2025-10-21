# Анализ компонентов TypeScript проекта

## Обзор структуры

Проект `nova-spec-ide-studio-main` содержит следующие основные категории компонентов:

### 1. Основные компоненты приложения (Custom Components)
Расположены в `src/components/`:

- **AIAssistant.tsx** - AI-ассистент с чатом, историей и шаблонами
- **FileExplorer.tsx** - Файловый менеджер с деревом директорий
- **TextEditor.tsx** - Текстовый редактор с сохранением
- **SpecPreview.tsx** - Предпросмотр спецификаций
- **StatusBar.tsx** - Статус-бар приложения
- **SwaggerViewer.tsx** - Просмотр Swagger документации
- **TopBar.tsx** - Верхняя панель инструментов

### 2. Диалоговые окна (Dialogs)
Расположены в `src/components/dialogs/`:

- **AboutDialog.tsx** - Окно "О программе"
- **AddTemplateDialog.tsx** - Добавление шаблона
- **AddTemplateTypeDialog.tsx** - Добавление типа шаблона
- **ErrorDialog.tsx** - Окно ошибок
- **MusicifyDialog.tsx** - Музыкальный диалог
- **OnboardingDialog.tsx** - Онбординг
- **SettingsDialog.tsx** - Настройки
- **TemplatesDialog.tsx** - Управление шаблонами

### 3. UI компоненты (UI Components)
Расположены в `src/components/ui/` - базируются на shadcn/ui:

- **button.tsx** - Кнопки с вариантами (default, destructive, outline, secondary, ghost, link)
- **textarea.tsx** - Текстовые области
- **dialog.tsx** - Диалоговые окна (Radix UI)
- **alert.tsx** - Уведомления
- **card.tsx** - Карточки
- **input.tsx** - Поля ввода
- **select.tsx** - Выпадающие списки
- **tooltip.tsx** - Всплывающие подсказки
- И другие 40+ UI компонентов

## Детальный анализ основных компонентов

### AIAssistant.tsx
**Функциональность:**
- Чат с AI моделями (GPT-5, Claude, Gemini и др.)
- История чатов
- Режим шаблонов для создания ТЗ
- Вставка файлов через @ символ
- Предложенные изменения с принятием/отклонением

**Ключевые состояния:**
```typescript
interface Message {
  role: "user" | "assistant";
  content: string;
}

interface ChatHistory {
  id: string;
  title: string;
  messages: Message[];
}
```

**Используемые UI компоненты:**
- Button, Textarea, Select, ScrollArea
- Tooltip, Popover
- Lucide React иконки

### FileExplorer.tsx
**Функциональность:**
- Древовидная структура файлов и папок
- Иконки для разных типов файлов
- Раскрытие/сворачивание папок
- Интеграция с логотипом NovaSpec

**Ключевые структуры:**
```typescript
interface FileNode {
  name: string;
  type: "file" | "folder";
  children?: FileNode[];
}
```

**Типы файлов с иконками:**
- .md - FileText (синий)
- .html - FileCode (оранжевый)
- .json - FileJson (желтый)
- .xml/.yaml/.yml - FileCode (разные цвета)
- .mp3/.wav - Music/FileAudio (розовый/голубой)

### TextEditor.tsx
**Функциональность:**
- Редактирование текстовых файлов
- Сохранение с toast уведомлением
- Поддержка JSON формата по умолчанию
- Моноширинный шрифт для кода

**Особенности:**
- Использует Textarea компонент
- Интеграция с sonner для toast
- Простая реализация без синтаксической подсветки

### SpecPreview.tsx
**Функциональность:**
- Предпросмотр спецификаций (MD, HTML)
- Переключение между режимами редактирования и просмотра
- Поддержка OpenAPI спецификаций (JSON/YAML)
- Интеграция со SwaggerViewer
- Музыкальная функция для MD/HTML файлов
- Вкладки для нескольких открытых файлов

**Ключевые особенности:**
- Использует useMemo для оптимизации
- Определение типа файла для выбора рендерера
- Поддержка PlantUML и Mermaid (пока не реализовано)
- Встроенный просмотр технических заданий

### SwaggerViewer.tsx
**Функциональность:**
- Просмотр OpenAPI спецификаций
- Поддержка JSON и YAML форматов
- Интеграция со swagger-ui-react

**Особенности:**
- Простая обертка над SwaggerUI
- Автоматическое определение формата (JSON/YAML)

### TopBar.tsx
**Функциональность:**
- Меню приложения (Файл, Настройки, О программе)
- Индикаторы AI-провайдера, Atlassian, Музыки
- Горячие клавиши
- Обновление баланса музыки

**Особенности:**
- Использует Menubar компонент
- Динамические индикаторы состояния
- Tooltip для подсказок

## Анализ UI компонентов

### Архитектура shadcn/ui
- Базируется на Radix UI primitives
- Использует class-variance-authority (cva) для вариантов
- Tailwind CSS для стилизации
- TypeScript с полной типизацией

### Button компонент
**Варианты:**
- default, destructive, outline, secondary, ghost, link
- Размеры: default, sm, lg, icon
- Поддержка asChild для кастомных элементов

### Dialog компонент
**Особенности:**
- Полностью основан на Radix UI Dialog
- Анимации входа/выхода
- Мобильная адаптация
- Композиционная структура (Header, Footer, Title, Description)

### Textarea компонент
**Особенности:**
- Минимальная высота 80px
- Фокус стили с ring
- Поддержка disabled состояния
- Полная совместимость с HTML textarea attributes

### Card компонент
**Структура:**
- Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent
- Композиционная структура
- Тени и границы по умолчанию

### Input компонент
**Особенности:**
- Поддержка всех HTML input типов
- Фокус стили с ring
- Адаптивный размер текста (md:text-sm)
- Поддержка file input с кастомными стилями

### Tooltip компонент
**Особенности:**
- Основан на Radix UI Tooltip
- Анимации появления/исчезновения
- Позиционирование (sideOffset)
- Z-index для корректного отображения

## React-специфичные паттерны

### 1. Хуки состояния
```typescript
const [isCollapsed, setIsCollapsed] = useState(false);
const [currentMessages, setCurrentMessages] = useState<Message[]>(mockMessages);
```

### 2. Рефы для DOM доступа
```typescript
const textareaRef = useRef<HTMLTextAreaElement>(null);
```

### 3. Композиция компонентов
```typescript
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon">
        <ChevronLeft className="w-4 h-4" />
      </Button>
    </TooltipTrigger>
    <TooltipContent side="left">
      <p>Развернуть AI-ассистент</p>
    </TooltipContent>
  </Tooltip>
</TooltipProvider>
```

### 4. Условный рендеринг
```typescript
{mode === "template" && (
  <div className="mb-4 p-3 rounded-lg border border-border bg-muted/50">
    {/* Template content */}
  </div>
)}
```

### 5. Маппинг массивов
```typescript
{mockChatHistory.map((chat) => (
  <button key={chat.id} onClick={() => handleHistorySelect(chat)}>
    {chat.title}
  </button>
))}
```

## Иконки и ресурсы

### Lucide React
Основная библиотека иконок:
- RotateCw, Plus, Brain, Send
- ChevronRight, ChevronLeft
- MessageSquarePlus, History, FileText, MessageCircle
- Check, XCircle, File, Folder, FileText, FileJson, FileCode

### SVG ресурсы
- novaspec-logo.svg в assets/
- atlassian-icon.svg в assets/

## Стили и темы

### Tailwind CSS классы
- **Цветовая схема:** primary, secondary, muted, accent, destructive
- **Бордеры:** border, border-border, border-input
- **Фоны:** bg-background, bg-panel, bg-muted
- **Тексты:** text-foreground, text-muted-foreground, text-primary

### Анимации
- transition-colors для плавных цветовых переходов
- hover: состояния для интерактивности
- Анимации Radix UI для диалогов

## Интеграции

### Внешние библиотеки
- **@radix-ui/react-*** - Low-level UI primitives
- **class-variance-authority** - Варианты компонентов
- **lucide-react** - Иконки
- **sonner** - Toast уведомления

### Паттерны интеграции
- Композиция вместо наследования
- Пропсы для конфигурации
- Callback функции для событий
- TypeScript интерфейсы для типизации

## Потенциальные сложности для миграции во Flutter

### 1. Система компонентов
- React: функциональные компоненты + хуки
- Flutter: Widget классы + StatefulWidget/StatelessWidget

### 2. Управление состоянием
- React: useState, useContext
- Flutter: setState, Provider, Bloc

### 3. Стили
- React: Tailwind CSS классы
- Flutter: ThemeData, TextStyle, Decoration

### 4. Анимации
- React: CSS transitions, Radix animations
- Flutter: AnimationController, Tween

### 5. Диалоги
- React: Компоненты-обертки
- Flutter: showDialog, showDialogRoute

### 6. Иконки
- React: Lucide React компоненты
- Flutter: IconData, Icon widget

## Рекомендации по миграции

### 1. Сохранение архитектуры
- Сохранить разделение на Custom/UI/Dialogs компоненты
- Использовать композицию паттернов

### 2. Адаптация UI компонентов
- Использовать Material Design 3 как эквивалент shadcn/ui
- Создать аналогичные варианты кнопок и полей

### 3. Управление состоянием
- Provider для глобального состояния
- StatefulWidget для локального состояния

### 4. Навигация
- Flutter Navigator для маршрутизации
- DialogRoute для модальных окон

### 5. Стили
- ThemeData для глобальной темы
- Кастомные темы для соответствия дизайну