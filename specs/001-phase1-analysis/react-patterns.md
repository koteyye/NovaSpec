# React-Specific Patterns Found in TypeScript Project

## Обзор

Проект использует современные React паттерны с TypeScript. Основные особенности:
- Функциональные компоненты с хуками
- Композиция вместо наследования
- TypeScript для типизации
- Radix UI для доступности

## 1. Хуки состояния (State Hooks)

### useState для локального состояния
```typescript
const [isCollapsed, setIsCollapsed] = useState(false);
const [currentMessages, setCurrentMessages] = useState<Message[]>(mockMessages);
const [selectedModel, setSelectedModel] = useState("GPT-5");
const [inputValue, setInputValue] = useState("");
```

### useRef для DOM доступа
```typescript
const textareaRef = useRef<HTMLTextAreaElement>(null);

// Использование
const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
  const value = e.target.value;
  const cursorPos = e.target.selectionStart;
  setInputValue(value);
  setCursorPosition(cursorPos);
};
```

### useMemo для оптимизации вычислений
```typescript
const fileContent = useMemo(() => {
  if (!activeFileObj) return "";
  
  switch (activeFileObj.path) {
    case "/api_openapi.json":
      return mockOpenAPIJson;
    case "/api_openapi.yaml":
      return mockOpenAPIYaml;
    default:
      return "";
  }
}, [activeFileObj]);

const isOpenAPI = useMemo(() => {
  if (!activeFileObj || !['json', 'yaml'].includes(activeFileObj.type)) return false;
  return isOpenAPISpec(fileContent);
}, [activeFileObj, fileContent]);
```

### useCallback для мемоизации функций
```typescript
const handleFileSelect = useCallback((file: FileReference) => {
  const beforeAt = inputValue.substring(0, inputValue.lastIndexOf("@"));
  const afterCursor = inputValue.substring(cursorPosition);
  setInputValue(`${beforeAt}@${file.name} ${afterCursor}`);
  setShowFileMenu(false);
}, [inputValue, cursorPosition]);
```

## 2. Паттерны рендеринга

### Условный рендеринг
```typescript
// Тернарный оператор
{mode === "template" && (
  <div className="mb-4 p-3 rounded-lg border border-border bg-muted/50">
    <div className="text-sm font-medium mb-1">Текущий шаблон:</div>
    <div className="text-sm text-primary">{selectedTemplate}</div>
  </div>
)}

// Сложные условия
{editMode || (!canRender && !shouldShowSwagger) ? (
  <TextEditor fileName={activeFileObj?.name || "untitled"} initialContent={fileContent} />
) : shouldShowSwagger ? (
  <SwaggerViewer spec={fileContent} />
) : canRender ? (
  <div className="flex-1 overflow-y-auto">
    {/* Preview content */}
  </div>
) : null}
```

### Маппинг массивов
```typescript
{mockChatHistory.map((chat) => (
  <button
    key={chat.id}
    onClick={() => handleHistorySelect(chat)}
    className="w-full text-left p-3 rounded-lg hover:bg-muted transition-colors border border-border"
  >
    <p className="text-sm text-foreground">{chat.title}</p>
  </button>
))}

{currentMessages.map((message, idx) => (
  <div
    key={idx}
    className={`flex gap-3 ${message.role === "user" ? "justify-end" : "justify-start"}`}
  >
    {/* Message content */}
  </div>
))}
```

### Фрагменты
```typescript
// React Fragment для группировки элементов
<>
  <div className="flex gap-2">
    <Button variant="outline" size="icon">
      <RotateCw className="w-4 h-4" />
    </Button>
    <Button variant="outline" size="icon">
      <Plus className="w-4 h-4" />
    </Button>
  </div>
  <div className="mt-2">
    {/* Additional content */}
  </div>
</>
```

## 3. Паттерны композиции

### Композиция компонентов
```typescript
// TooltipProvider + Tooltip + TooltipTrigger + TooltipContent
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" onClick={handleNewChat}>
        <MessageSquarePlus className="w-4 h-4" />
      </Button>
    </TooltipTrigger>
    <TooltipContent>
      <p>Новый чат</p>
    </TooltipContent>
  </Tooltip>
</TooltipProvider>

// Dialog композиция
<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>
      <DialogDescription>Description</DialogDescription>
    </DialogHeader>
    {/* Content */}
    <DialogFooter>
      <Button>Save</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

### asChild паттерн
```typescript
// Полная передача пропсов дочернему элементу
<TooltipTrigger asChild>
  <Button variant="ghost" size="icon">
    <ChevronLeft className="w-4 h-4" />
  </Button>
</TooltipTrigger>

// В Button компоненте
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />;
  }
);
```

### Render props паттерн
```typescript
// Использование children как функции
interface FileTreeItemProps {
  node: FileNode;
  depth?: number;
  renderIcon?: (fileName: string) => React.ReactNode;
}

const FileTreeItem = ({ node, depth = 0, renderIcon = getFileIcon }: FileTreeItemProps) => {
  return (
    <div>
      {renderIcon(node.name)}
      <span>{node.name}</span>
    </div>
  );
};
```

## 4. Паттерны обработки событий

### Обработчики событий
```typescript
// События форм
const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
  const value = e.target.value;
  const cursorPos = e.target.selectionStart;
  setInputValue(value);
  setCursorPosition(cursorPos);
};

// Клик события
const handleFileSelect = (file: FileReference) => {
  const beforeAt = inputValue.substring(0, inputValue.lastIndexOf("@"));
  const afterCursor = inputValue.substring(cursorPosition);
  setInputValue(`${beforeAt}@${file.name} ${afterCursor}`);
  setShowFileMenu(false);
};

// Предотвращение всплытия
<button
  onClick={(e) => {
    e.stopPropagation();
    // Handle close file
  }}
>
  <X className="w-3 h-3" />
</button>
```

### События клавиатуры
```typescript
const handleKeyDown = (e: KeyboardEvent) => {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    handleSend();
  }
};
```

## 5. Паттерны работы с пропсами

### Деструктуризация пропсов
```typescript
interface AIAssistantProps {
  onOpenFile?: (path: string) => void;
}

export const AIAssistant = ({ onOpenFile }: AIAssistantProps) => {
  // Component implementation
};

interface SpecPreviewProps {
  musicActive?: boolean;
  openFiles?: { name: string; path: string; type: string }[];
  activeFile?: string;
  onFileChange?: (path: string) => void;
  onMusicify?: () => void;
}

export const SpecPreview = ({ 
  musicActive = false, 
  openFiles = [{ name: "spec_v1.md", path: "/spec_v1.md", type: "md" }],
  activeFile = "/spec_v1.md",
  onFileChange,
  onMusicify
}: SpecPreviewProps) => {
  // Component implementation
};
```

### Spread оператор для пропсов
```typescript
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />;
  }
);
```

### Пропсы для конфигурации
```typescript
// Варианты через пропсы
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>, VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

// Использование
<Button variant="outline" size="icon" onClick={handleClick}>
  <Icon />
</Button>
```

## 6. Паттерны TypeScript

### Интерфейсы для типизации
```typescript
interface Message {
  role: "user" | "assistant";
  content: string;
}

interface FileReference {
  name: string;
  path: string;
}

interface ChatHistory {
  id: string;
  title: string;
  messages: Message[];
}

interface FileNode {
  name: string;
  type: "file" | "folder";
  children?: FileNode[];
}
```

### Generic типы
```typescript
// ForwardRef с generic
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    // Implementation
  }
);

// Расширение HTML атрибутов
export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {}

export interface InputProps extends React.ComponentProps<"input"> {}
```

### VariantProps из CVA
```typescript
import { type VariantProps } from "class-variance-authority";

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}
```

## 7. Паттерны оптимизации

### React.memo для мемоизации компонентов
```typescript
const FileTreeItem = React.memo(({ node, depth = 0 }: { node: FileNode; depth?: number }) => {
  const [expanded, setExpanded] = useState(depth === 0);
  
  // Component implementation
});
```

### useMemo для дорогих вычислений
```typescript
const filteredFiles = useMemo(() => {
  return files.filter(file => 
    file.name.toLowerCase().includes(searchTerm.toLowerCase())
  );
}, [files, searchTerm]);
```

### useCallback для стабильных ссылок
```typescript
const handleSubmit = useCallback((data: FormData) => {
  onSubmit(data);
}, [onSubmit]);
```

## 8. Паттерны работы со сторонними библиотеками

### Radix UI паттерны
```typescript
// Portal паттерн
<DialogPortal>
  <DialogOverlay />
  <DialogPrimitive.Content>
    {/* Content */}
  </DialogPrimitive.Content>
</DialogPortal>

// Primitive композиция
const Select = SelectPrimitive.Root;
const SelectTrigger = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Trigger>
>(({ className, children, ...props }, ref) => (
  <SelectPrimitive.Trigger ref={ref} className={cn(/* styles */)} {...props}>
    {children}
    <SelectPrimitive.Icon asChild>
      <ChevronDown className="h-4 w-4 opacity-50" />
    </SelectPrimitive.Icon>
  </SelectPrimitive.Trigger>
));
```

### Sonner toast паттерн
```typescript
import { toast } from "sonner";

const handleSave = () => {
  toast.success(`Файл ${fileName} сохранен`);
};

toast.error("Ошибка сохранения файла");
toast.info("Информационное сообщение");
```

## 9. Паттерны стилизации

### Условные классы
```typescript
className={cn(
  "базовые классы",
  isActive && "active классы",
  variant === "primary" && "primary классы",
  className // пропсы для переопределения
)}

// Динамические классы
className={`flex gap-3 ${message.role === "user" ? "justify-end" : "justify-start"}`}
```

### CVA для вариантов
```typescript
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        // ...
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);
```

## 10. Паттерны работы с данными

### Мок данные
```typescript
const mockMessages: Message[] = [
  { role: "user", content: "Добавь раздел про уведомления" },
  {
    role: "assistant",
    content: "Добавляю раздел про уведомления в техническое задание.",
  },
];

const mockFiles: FileReference[] = [
  { name: "spec_v1.md", path: "/spec_v1.md" },
  { name: "spec_v2.html", path: "/spec_v2.html" },
  { name: "requirements.json", path: "/requirements.json" },
];
```

### Обработка данных
```typescript
// Поиск в массивах
const activeFileObj = openFiles.find(f => f.path === activeFile);

// Фильтрация
const canMusicify = activeFileObj && (activeFileObj.type === "md" || activeFileObj.type === "html");

// Условная логика
const shouldShowSwagger = !editMode && isOpenAPI && ['json', 'yaml'].includes(activeFileObj?.type || '');
```

## Потенциальные сложности для Flutter миграции

### 1. Хуки → StatefulWidget
```typescript
// React
const [count, setCount] = useState(0);

// Flutter
class _CounterState extends State<Counter> {
  int count = 0;
  
  void setCount(int value) {
    setState(() {
      count = value;
    });
  }
}
```

### 2. JSX → Widget дерево
```typescript
// React
<div className="flex gap-2">
  <Button>Click</Button>
  <Text>Hello</Text>
</div>

// Flutter
Row(
  children: [
    ElevatedButton(onPressed: () {}, child: Text('Click')),
    Text('Hello'),
  ],
)
```

### 3. Условный рендеринг
```typescript
// React
{condition && <Component />}

// Flutter
condition ? Component() : Container(),
// или
if (condition) Component() else Container(),
```

### 4. Маппинг массивов
```typescript
// React
{items.map(item => <Item key={item.id} data={item} />)}

// Flutter
Column(
  children: items.map((item) => Item(data: item)).toList(),
)
```

### 5. Композиция
```typescript
// React
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button>Click</Button>
    </TooltipTrigger>
    <TooltipContent>Hint</TooltipContent>
  </Tooltip>
</TooltipProvider>

// Flutter
Tooltip(
  message: 'Hint',
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Click'),
  ),
)
```

## Рекомендации по миграции

### 1. StatefulWidget для состояния
- useState → State класс
- useEffect → initState/didChangeDependencies/dispose
- useMemo → Computed свойства или кэширование

### 2. StatelessWidget для статического контента
- Простой рендер пропсов
- Без внутреннего состояния

### 3. Параметры вместо пропсов
```dart
class CustomButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Widget? child;
  
  const CustomButton({
    Key? key,
    this.variant = ButtonVariant.default,
    this.size = ButtonSize.default,
    this.onPressed,
    this.child,
  }) : super(key: key);
}
```

### 4. Композиция виджетов
```dart
class CustomCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final List<Widget>? actions;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (title != null || subtitle != null)
            CardHeader(
              title: title,
              subtitle: subtitle,
              actions: actions,
            ),
          CardContent(child: child),
        ],
      ),
    );
  }
}
```