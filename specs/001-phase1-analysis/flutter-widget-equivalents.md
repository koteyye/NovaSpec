# Flutter Widget Equivalents for TypeScript Components

## Обзор

Соответствие между React/TypeScript компонентами проекта и Flutter виджетами. Основной принцип:
- **React компоненты** → **Flutter виджеты**
- **JSX синтаксис** → **Widget дерево**
- **Props** → **Constructor параметры**
- **State hooks** → **StatefulWidget**
- **Composition** → **Widget композиция**

## 1. Основные компоненты приложения

### AIAssistant.tsx → Flutter эквиваленты

```typescript
// React TypeScript
interface Message {
  role: "user" | "assistant";
  content: string;
}

const AIAssistant = ({ onOpenFile }: AIAssistantProps) => {
  const [selectedModel, setSelectedModel] = useState("GPT-5");
  const [inputValue, setInputValue] = useState("");
  const [isCollapsed, setIsCollapsed] = useState(false);
  
  return (
    <div className="w-96 border-l border-border bg-panel flex flex-col h-full">
      {/* Content */}
    </div>
  );
};
```

```dart
// Flutter/Dart
class Message {
  final String role;
  final String content;
  
  Message({required this.role, required this.content});
}

class AIAssistant extends StatefulWidget {
  final Function(String)? onOpenFile;
  
  const AIAssistant({Key? key, this.onOpenFile}) : super(key: key);
  
  @override
  _AIAssistantState createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {
  String selectedModel = "GPT-5";
  String inputValue = "";
  bool isCollapsed = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 384, // w-96 = 24rem = 384px
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          // Header
          // Messages list
          // Input area
        ],
      ),
    );
  }
}
```

### FileExplorer.tsx → Flutter эквиваленты

```typescript
// React TypeScript
interface FileNode {
  name: string;
  type: "file" | "folder";
  children?: FileNode[];
}

const FileTreeItem = ({ node, depth = 0 }: { node: FileNode; depth?: number }) => {
  const [expanded, setExpanded] = useState(depth === 0);
  
  if (node.type === "file") {
    return (
      <div className="flex items-center gap-2 px-3 py-1.5">
        {getFileIcon(node.name)}
        <span className="text-sm truncate">{node.name}</span>
      </div>
    );
  }
  
  return (
    <div>
      <div onClick={() => setExpanded(!expanded)}>
        <Folder className="w-4 h-4" />
        <span>{node.name}</span>
      </div>
      {expanded && node.children?.map(child => (
        <FileTreeItem key={child.name} node={child} depth={depth + 1} />
      ))}
    </div>
  );
};
```

```dart
// Flutter/Dart
class FileNode {
  final String name;
  final String type; // "file" or "folder"
  final List<FileNode>? children;
  
  FileNode({required this.name, required this.type, this.children});
}

class FileTreeItem extends StatefulWidget {
  final FileNode node;
  final int depth;
  
  const FileTreeItem({Key? key, required this.node, this.depth = 0}) : super(key: key);
  
  @override
  _FileTreeItemState createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<FileTreeItem> {
  late bool expanded;
  
  @override
  void initState() {
    super.initState();
    expanded = widget.depth == 0;
  }
  
  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'md':
        return Icon(Icons.description, color: Colors.blue, size: 16);
      case 'json':
        return Icon(Icons.code, color: Colors.yellow, size: 16);
      case 'html':
        return Icon(Icons.web, color: Colors.orange, size: 16);
      default:
        return Icon(Icons.insert_drive_file, size: 16);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.node.type == "file") {
      return Padding(
        padding: EdgeInsets.only(left: widget.depth * 16.0 + 12.0),
        child: InkWell(
          onTap: () {
            // Handle file selection
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              children: [
                _getFileIcon(widget.node.name),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.node.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: EdgeInsets.only(left: widget.depth * 16.0 + 12.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  Icon(Icons.folder, color: Colors.blueAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    widget.node.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.medium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded && widget.node.children != null)
          ...widget.node.children!.map((child) => FileTreeItem(
            key: ValueKey(child.name),
            node: child,
            depth: widget.depth + 1,
          )),
      ],
    );
  }
}
```

### TextEditor.tsx → Flutter эквиваленты

```typescript
// React TypeScript
const TextEditor = ({ fileName, initialContent }: TextEditorProps) => {
  const [content, setContent] = useState(initialContent);
  
  return (
    <div className="flex-1 bg-background flex flex-col h-full">
      <div className="border-b border-border px-4 py-2">
        <span>{fileName}</span>
        <Button onClick={handleSave}>
          <Save className="w-4 h-4" />
        </Button>
      </div>
      <Textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        className="flex-1 font-mono text-sm"
      />
    </div>
  );
};
```

```dart
// Flutter/Dart
class TextEditor extends StatefulWidget {
  final String fileName;
  final String? initialContent;
  
  const TextEditor({Key? key, required this.fileName, this.initialContent}) : super(key: key);
  
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void handleSave() {
    // Show snackbar instead of toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Файл ${widget.fileName} сохранен')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.fileName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              IconButton(
                onPressed: handleSave,
                icon: Icon(Icons.save, size: 16),
                tooltip: 'Сохранить',
              ),
            ],
          ),
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
              hintText: 'Начните вводить текст...',
            ),
          ),
        ),
      ],
    );
  }
}
```

## 2. UI компоненты

### Button → Flutter Buttons

```typescript
// React TypeScript
const Button = ({ variant = "default", size = "default", children, ...props }) => {
  return (
    <button className={cn(buttonVariants({ variant, size }))} {...props}>
      {children}
    </button>
  );
};

// Использование
<Button variant="outline" size="icon">
  <ChevronLeft className="w-4 h-4" />
</Button>
```

```dart
// Flutter/Dart
enum ButtonVariant { default, destructive, outline, secondary, ghost, link }
enum ButtonSize { default, small, large, icon }

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
  
  ButtonStyle getButtonStyle(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.default:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
        );
      case ButtonVariant.ghost:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
        );
      default:
        return ElevatedButton.styleFrom();
    }
  }
  
  double getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.large:
        return 44;
      case ButtonSize.icon:
        return 40;
      default:
        return 40;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = getHeight();
    
    if (size == ButtonSize.icon) {
      return SizedBox(
        width: height,
        height: height,
        child: IconButton(
          onPressed: onPressed,
          icon: child ?? Container(),
          style: getButtonStyle(theme),
        ),
      );
    }
    
    return SizedBox(
      height: height,
      child: variant == ButtonVariant.outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: getButtonStyle(theme),
              child: child,
            )
          : variant == ButtonVariant.ghost
              ? TextButton(
                  onPressed: onPressed,
                  style: getButtonStyle(theme),
                  child: child,
                )
              : ElevatedButton(
                  onPressed: onPressed,
                  style: getButtonStyle(theme),
                  child: child,
                ),
    );
  }
}

// Использование
CustomButton(
  variant: ButtonVariant.outline,
  size: ButtonSize.icon,
  onPressed: () {},
  child: Icon(Icons.keyboard_arrow_left, size: 16),
)
```

### Dialog → Flutter Dialog

```typescript
// React TypeScript
const Dialog = ({ children, open, onOpenChange }) => {
  return (
    <DialogRoot open={open} onOpenChange={onOpenChange}>
      <DialogPortal>
        <DialogOverlay />
        <DialogContent>
          {children}
        </DialogContent>
      </DialogPortal>
    </DialogRoot>
  );
};
```

```dart
// Flutter/Dart
class CustomDialog extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final List<Widget>? actions;
  
  const CustomDialog({
    Key? key,
    required this.title,
    this.content,
    this.actions,
  }) : super(key: key);
  
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    Widget? content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }
}

// Использование
CustomDialog.show(
  context: context,
  title: Text('Заголовок'),
  content: Text('Содержимое диалога'),
  actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('Отмена'),
    ),
    ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('OK'),
    ),
  ],
);
```

### Tooltip → Flutter Tooltip

```typescript
// React TypeScript
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button>
        <Icon />
      </Button>
    </TooltipTrigger>
    <TooltipContent>
      <p>Подсказка</p>
    </TooltipContent>
  </Tooltip>
</TooltipProvider>
```

```dart
// Flutter/Dart
Tooltip(
  message: 'Подсказка',
  child: ElevatedButton(
    onPressed: () {},
    child: Icon(Icons.some_icon),
  ),
)
```

### Select → Flutter DropdownButton

```typescript
// React TypeScript
const Select = ({ value, onValueChange, children }) => {
  return (
    <SelectRoot value={value} onValueChange={onValueChange}>
      <SelectTrigger>
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {children}
      </SelectContent>
    </SelectRoot>
  );
};
```

```dart
// Flutter/Dart
class CustomSelect<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  
  const CustomSelect({
    Key? key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      hint: hint != null ? Text(hint!) : null,
      isExpanded: true,
      underline: Container(
        height: 1,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
      ),
    );
  }
}

// Использование
CustomSelect<String>(
  value: selectedModel,
  hint: 'Выберите модель',
  items: models.map((model) {
    return DropdownMenuItem<String>(
      value: model,
      child: Text(model),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedModel = value;
    });
  },
)
```

## 3. Layout компоненты

### Flexbox → Flutter Row/Column

```typescript
// React TypeScript
<div className="flex items-center justify-between gap-2">
  <Button>Left</Button>
  <Button>Right</Button>
</div>

<div className="flex flex-col gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

```dart
// Flutter/Dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    CustomButton(child: Text('Left')),
    SizedBox(width: 8),
    CustomButton(child: Text('Right')),
  ],
)

Column(
  children: [
    Text('Item 1'),
    SizedBox(height: 16),
    Text('Item 2'),
  ],
)
```

### Grid → Flutter GridView

```typescript
// React TypeScript
<div className="grid grid-cols-2 gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

```dart
// Flutter/Dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  children: [
    Text('Item 1'),
    Text('Item 2'),
  ],
)
```

### ScrollArea → Flutter SingleChildScrollView

```typescript
// React TypeScript
<ScrollArea className="flex-1">
  <div>Long content</div>
</ScrollArea>
```

```dart
// Flutter/Dart
SingleChildScrollView(
  child: Text('Long content'),
)

// или с кастомным скроллбар
Scrollbar(
  child: SingleChildScrollView(
    child: Text('Long content'),
  ),
)
```

## 4. Стили и темы

### Tailwind классы → Flutter ThemeData

```typescript
// React TypeScript
<div className="bg-primary text-primary-foreground p-4 rounded-lg border border-border">
  <h1 className="text-2xl font-bold">Title</h1>
  <p className="text-sm text-muted-foreground">Description</p>
</div>
```

```dart
// Flutter/Dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Theme.of(context).dividerColor),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Title',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Description',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
        ),
      ),
    ],
  ),
)
```

### CVA варианты → Flutter параметры

```typescript
// React TypeScript с CVA
const buttonVariants = cva(
  "base classes",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground",
        outline: "border border-input bg-background",
      },
      size: {
        default: "h-10 px-4",
        sm: "h-9 px-3",
      },
    },
  }
);
```

```dart
// Flutter/Dart
class CustomButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  
  const CustomButton({
    this.variant = ButtonVariant.default,
    this.size = ButtonSize.default,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _getPadding(),
      decoration: _getDecoration(context),
      child: Text('Button', style: _getTextStyle(context)),
    );
  }
  
  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      default:
        return EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }
  
  BoxDecoration _getDecoration(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case ButtonVariant.default:
        return BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        );
      case ButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(6),
        );
      default:
        return BoxDecoration(borderRadius: BorderRadius.circular(6));
    }
  }
}
```

## 5. Иконки

### Lucide React → Flutter Icons

```typescript
// React TypeScript
import { ChevronLeft, Save, Brain, Folder } from "lucide-react";

<ChevronLeft className="w-4 h-4" />
<Save className="w-4 h-4" />
<Brain className="w-4 h-4" />
<Folder className="w-4 h-4" />
```

```dart
// Flutter/Dart
Icon(Icons.keyboard_arrow_left, size: 16)
Icon(Icons.save, size: 16)
Icon(Icons.psychology, size: 16) // или кастомная иконка
Icon(Icons.folder, size: 16)

// Для SVG ассетов
Image.asset('assets/images/novaspec-logo.svg', width: 24, height: 24)
Image.asset('assets/images/atlassian-icon.svg', width: 24, height: 24)
```

## 6. Анимации

### CSS transitions → Flutter Animations

```typescript
// React TypeScript
<div className="transition-colors hover:bg-accent">
  Animated content
</div>
```

```dart
// Flutter/Dart
class AnimatedContainer extends StatefulWidget {
  final Widget child;
  
  const AnimatedContainer({Key? key, required this.child}) : super(key: key);
  
  @override
  _AnimatedContainerState createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<AnimatedContainer> {
  bool isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered 
              ? Theme.of(context).colorScheme.surfaceVariant
              : Colors.transparent,
        ),
        child: widget.child,
      ),
    );
  }
}
```

## 7. Формы

### React формы → Flutter Forms

```typescript
// React TypeScript
const [formData, setFormData] = useState({
  name: '',
  email: '',
});

return (
  <form>
    <Input
      value={formData.name}
      onChange={(e) => setFormData({...formData, name: e.target.value})}
      placeholder="Name"
    />
    <Input
      value={formData.email}
      onChange={(e) => setFormData({...formData, email: e.target.value})}
      placeholder="Email"
    />
  </form>
);
```

```dart
// Flutter/Dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
```

## 8. Состояние и副作用

### useEffect → Flutter lifecycle

```typescript
// React TypeScript
useEffect(() => {
  // Component did mount
  loadData();
  
  return () => {
    // Component will unmount
    cleanup();
  };
}, [dependency]);
```

```dart
// Flutter/Dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Component did mount
    loadData();
  }
  
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Component did update (when dependencies change)
  }
  
  @override
  void dispose() {
    // Component will unmount
    cleanup();
    super.dispose();
  }
}
```

## 9. Навигация

### React Router → Flutter Navigator

```typescript
// React TypeScript
import { useNavigate } from "react-router-dom";

const MyComponent = () => {
  const navigate = useNavigate();
  
  const handleNavigate = () => {
    navigate('/settings');
  };
  
  return <Button onClick={handleNavigate}>Go to Settings</Button>;
};
```

```dart
// Flutter/Dart
class MyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/settings');
      },
      child: Text('Go to Settings'),
    );
  }
}
```

## 10. Toast уведомления

### Sonner → Flutter SnackBar

```typescript
// React TypeScript
import { toast } from "sonner";

const handleSave = () => {
  toast.success("Файл сохранен");
  toast.error("Ошибка сохранения");
};
```

```dart
// Flutter/Dart
class MyWidget extends StatelessWidget {
  void handleSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Файл сохранен'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void handleError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ошибка сохранения'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## Резюме соответствий

| React/TypeScript | Flutter/Dart | Примечания |
|------------------|--------------|------------|
| `useState` | `StatefulWidget` | Локальное состояние |
| `useEffect` | `initState/didUpdate/dispose` | Lifecycle методы |
| `useMemo` | `computed` свойства | Оптимизация вычислений |
| `useCallback` | Методы класса | Стабильные ссылки |
| `JSX` | `Widget дерево` | Декларативный UI |
| `Props` | `Constructor параметры` | Передача данных |
| `Composition` | `Widget композиция` | Композиция виджетов |
| `Tailwind CSS` | `ThemeData` | Система стилей |
| `CVA` | `Параметры виджета` | Варианты компонентов |
| `Lucide React` | `Icons` | Иконки |
| `Radix UI` | `Material widgets` | Доступность |
| `React Router` | `Navigator` | Навигация |
| `Sonner` | `SnackBar` | Уведомления |
| `Portals` | `Overlay/Stack` | Портальный рендеринг |
| `forwardRef` | `GlobalKey` | Ref доступ |