import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { RotateCw, Plus, Brain, Send, ChevronRight, ChevronLeft, MessageSquarePlus, History, FileText, MessageCircle, Check, XCircle } from "lucide-react";
import { useState, useRef, KeyboardEvent } from "react";

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

const mockMessages: Message[] = [
  { role: "user", content: "Добавь раздел про уведомления" },
  {
    role: "assistant",
    content:
      "Добавляю раздел про уведомления в техническое задание. Включу описание типов уведомлений, настройки и технические требования.",
  },
  { role: "user", content: "Добавь также информацию про push-уведомления" },
  {
    role: "assistant",
    content:
      "Раздел обновлен. Добавлено описание push-уведомлений, включая интеграцию с Firebase Cloud Messaging и требования к разрешениям.",
  },
];

const mockChatHistory: ChatHistory[] = [
  { id: "1", title: "Уведомления / Push / Настройки", messages: mockMessages },
  { id: "2", title: "Архитектура / Backend / API", messages: [] },
  { id: "3", title: "UI/UX / Дизайн / Компоненты", messages: [] },
];

const mockFiles: FileReference[] = [
  { name: "spec_v1.md", path: "/spec_v1.md" },
  { name: "spec_v2.html", path: "/spec_v2.html" },
  { name: "requirements.json", path: "/requirements.json" },
];

const models = [
  "GPT-5",
  "GPT-5 Mini",
  "GPT-5 Nano",
  "Claude 4 Opus",
  "Claude 4 Sonnet",
  "Gemini 2.5 Pro",
  "Gemini 2.5 Flash",
  "Llama 3.3 70B",
  "Qwen 2.5 72B",
  "DeepSeek V3",
];

interface AIAssistantProps {
  onOpenFile?: (path: string) => void;
}

export const AIAssistant = ({ onOpenFile }: AIAssistantProps) => {
  const [selectedModel, setSelectedModel] = useState("GPT-5");
  const [inputValue, setInputValue] = useState("");
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [showHistory, setShowHistory] = useState(false);
  const [currentMessages, setCurrentMessages] = useState<Message[]>(mockMessages);
  const [showFileMenu, setShowFileMenu] = useState(false);
  const [fileMenuPosition, setFileMenuPosition] = useState({ top: 0, left: 0 });
  const [cursorPosition, setCursorPosition] = useState(0);
  const [mode, setMode] = useState<"chat" | "template">("chat");
  const [selectedTemplate, setSelectedTemplate] = useState("Базовый шаблон ТЗ");
  const [showProposedChanges, setShowProposedChanges] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    const cursorPos = e.target.selectionStart;
    
    setInputValue(value);
    setCursorPosition(cursorPos);

    // Check for @ symbol
    const lastAtIndex = value.lastIndexOf("@", cursorPos - 1);
    if (lastAtIndex !== -1 && lastAtIndex === cursorPos - 1) {
      const rect = e.target.getBoundingClientRect();
      setFileMenuPosition({ top: rect.top, left: rect.left });
      setShowFileMenu(true);
    } else {
      setShowFileMenu(false);
    }
  };

  const handleFileSelect = (file: FileReference) => {
    const beforeAt = inputValue.substring(0, inputValue.lastIndexOf("@"));
    const afterCursor = inputValue.substring(cursorPosition);
    setInputValue(`${beforeAt}@${file.name} ${afterCursor}`);
    setShowFileMenu(false);
  };

  const handleNewChat = () => {
    setCurrentMessages([]);
    setShowHistory(false);
  };

  const handleHistorySelect = (chat: ChatHistory) => {
    setCurrentMessages(chat.messages);
    setShowHistory(false);
  };

  if (isCollapsed) {
    return (
      <div className="border-l border-border bg-panel flex items-start justify-center pt-4">
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setIsCollapsed(false)}
              >
                <ChevronLeft className="w-4 h-4" />
              </Button>
            </TooltipTrigger>
            <TooltipContent side="left">
              <p>Развернуть AI-ассистент</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>
    );
  }

  return (
    <div className="w-96 border-l border-border bg-panel flex flex-col h-full">
      <div className="p-4 border-b border-border flex items-center justify-between">
        <div className="flex items-center gap-2">
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={handleNewChat}
                >
                  <MessageSquarePlus className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Новый чат</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setShowHistory(!showHistory)}
                >
                  <History className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>История чатов</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <div className="h-4 w-px bg-border mx-1" />

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant={mode === "chat" ? "default" : "ghost"}
                  size="icon"
                  onClick={() => setMode("chat")}
                >
                  <MessageCircle className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Диалог</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant={mode === "template" ? "default" : "ghost"}
                  size="icon"
                  onClick={() => setMode("template")}
                >
                  <FileText className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Создание ТЗ по шаблону</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>

        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setIsCollapsed(true)}
              >
                <ChevronRight className="w-4 h-4" />
              </Button>
            </TooltipTrigger>
            <TooltipContent>
              <p>Свернуть</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>

      <ScrollArea className="flex-1 p-4">
        {mode === "template" && (
          <div className="mb-4 p-3 rounded-lg border border-border bg-muted/50">
            <div className="text-sm font-medium mb-1">Текущий шаблон:</div>
            <div className="text-sm text-primary">{selectedTemplate}</div>
          </div>
        )}

        {showHistory ? (
          <div className="space-y-2">
            {mockChatHistory.map((chat) => (
              <button
                key={chat.id}
                onClick={() => handleHistorySelect(chat)}
                className="w-full text-left p-3 rounded-lg hover:bg-muted transition-colors border border-border"
              >
                <p className="text-sm text-foreground">{chat.title}</p>
              </button>
            ))}
          </div>
        ) : (
          <div className="space-y-4">
            {currentMessages.map((message, idx) => (
              <div
                key={idx}
                className={`flex gap-3 ${message.role === "user" ? "justify-end" : "justify-start"}`}
              >
                {message.role === "assistant" && (
                  <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                    <Brain className="w-4 h-4 text-primary-foreground" />
                  </div>
                )}
                <div
                  className={`max-w-[80%] p-3 rounded-lg ${
                    message.role === "user"
                      ? "bg-primary text-primary-foreground"
                      : "bg-muted text-foreground"
                  }`}
                >
                  <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                </div>
              </div>
            ))}

            {/* AI предлагаемые изменения */}
            {showProposedChanges && (
              <div className="p-4 border border-primary/30 rounded-lg bg-primary/5">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-sm font-semibold text-primary">AI предлагает изменения:</h4>
                  <div className="flex gap-2">
                    <Button size="sm" variant="default" onClick={() => setShowProposedChanges(false)}>
                      <Check className="w-3 h-3 mr-1" />
                      Принять
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => setShowProposedChanges(false)}>
                      <XCircle className="w-3 h-3 mr-1" />
                      Отклонить
                    </Button>
                  </div>
                </div>
                <div className="text-sm space-y-2">
                  <div className="bg-red-500/20 p-2 rounded line-through">
                    Старая версия функционала
                  </div>
                  <div className="bg-yellow-500/20 p-2 rounded">
                    Новая улучшенная версия функционала
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </ScrollArea>

      <div className="p-4 border-t border-border space-y-3">
        <div className="flex gap-2">
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="outline" size="icon">
                  <RotateCw className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Уточнить</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="outline" size="icon">
                  <Plus className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Расширить</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button 
                  variant="outline" 
                  size="icon"
                  onClick={() => setShowProposedChanges(true)}
                >
                  <Brain className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Регенерировать</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>

        <Popover>
          <PopoverTrigger asChild>
            <button className="text-xs text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
              model: {selectedModel}
            </button>
          </PopoverTrigger>
          <PopoverContent className="w-64 p-0" align="start">
            <ScrollArea className="max-h-80">
              <div className="p-1">
                {models.map((model) => (
                  <button
                    key={model}
                    onClick={() => setSelectedModel(model)}
                    className={`w-full text-left px-3 py-2 text-sm rounded hover:bg-muted transition-colors ${
                      selectedModel === model ? "bg-muted font-medium" : ""
                    }`}
                  >
                    {model}
                  </button>
                ))}
              </div>
            </ScrollArea>
          </PopoverContent>
        </Popover>

        <div className="flex gap-2 items-end relative">
          <Textarea
            ref={textareaRef}
            placeholder="Например: добавь раздел про уведомления. Используйте @ для выбора файла."
            value={inputValue}
            onChange={handleInputChange}
            className="flex-1 min-h-[80px] max-h-[160px] resize-none"
            rows={3}
          />
          <Button size="icon" className="shrink-0">
            <Send className="w-4 h-4" />
          </Button>

          {showFileMenu && (
            <div className="absolute bottom-full left-0 mb-2 w-full bg-popover border border-border rounded-lg shadow-lg z-50">
              <ScrollArea className="max-h-60">
                <div className="p-1">
                  {mockFiles.map((file) => (
                    <button
                      key={file.path}
                      onClick={() => handleFileSelect(file)}
                      className="w-full text-left px-3 py-2 text-sm rounded hover:bg-muted transition-colors flex items-center gap-2"
                    >
                      <FileText className="w-4 h-4" />
                      {file.name}
                    </button>
                  ))}
                </div>
              </ScrollArea>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
