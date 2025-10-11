import { Button } from "@/components/ui/button";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Music, X, Code2, Eye } from "lucide-react";
import { TextEditor } from "./TextEditor";
import { SwaggerViewer } from "./SwaggerViewer";
import { useState, useMemo } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { isOpenAPISpec, mockOpenAPIJson, mockOpenAPIYaml, mockRegularJson, mockRegularYaml } from "@/utils/openapi";

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
  const [editMode, setEditMode] = useState(false);
  
  const activeFileObj = openFiles.find(f => f.path === activeFile);
  const canMusicify = activeFileObj && (activeFileObj.type === "md" || activeFileObj.type === "html");
  const canRender = activeFileObj && ['md', 'html'].includes(activeFileObj.type);
  
  // Get file content based on type
  const fileContent = useMemo(() => {
    if (!activeFileObj) return "";
    
    switch (activeFileObj.path) {
      case "/api_openapi.json":
        return mockOpenAPIJson;
      case "/api_openapi.yaml":
        return mockOpenAPIYaml;
      case "/config.json":
        return mockRegularJson;
      case "/config.yaml":
        return mockRegularYaml;
      case "/requirements.json":
        return mockRegularJson;
      default:
        return "";
    }
  }, [activeFileObj]);
  
  // Check if current file is OpenAPI spec
  const isOpenAPI = useMemo(() => {
    if (!activeFileObj || !['json', 'yaml'].includes(activeFileObj.type)) return false;
    return isOpenAPISpec(fileContent);
  }, [activeFileObj, fileContent]);
  
  // Determine if file can toggle between code/preview
  const canToggleView = activeFileObj && !['mp3', 'wav'].includes(activeFileObj.type);
  
  // Should show swagger viewer
  const shouldShowSwagger = !editMode && isOpenAPI && ['json', 'yaml'].includes(activeFileObj?.type || '');

  return (
    <div className="flex-1 bg-editor flex flex-col overflow-hidden">
      {/* Вкладки файлов */}
      <div className="flex items-center gap-1 px-4 pt-2 border-b border-border bg-panel">
        {openFiles.map((file) => (
          <div
            key={file.path}
            className={`flex items-center gap-2 px-3 py-2 rounded-t-lg cursor-pointer transition-colors ${
              activeFile === file.path
                ? "bg-editor text-foreground"
                : "bg-muted/50 text-muted-foreground hover:bg-muted"
            }`}
            onClick={() => onFileChange?.(file.path)}
          >
            <span className="text-sm">{file.name}</span>
            <button
              className="hover:text-foreground"
              onClick={(e) => {
                e.stopPropagation();
                // Handle close file
              }}
            >
              <X className="w-3 h-3" />
            </button>
          </div>
        ))}
      </div>

      {/* Шапка с кнопками музикации и переключения режима */}
      {(musicActive && canMusicify) || canToggleView ? (
        <div className="px-4 py-2 border-b border-border bg-panel flex justify-end items-center gap-2">
          <TooltipProvider>
            {canToggleView && (
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={() => setEditMode(!editMode)}
                  >
                    {editMode ? <Eye className="w-4 h-4" /> : <Code2 className="w-4 h-4" />}
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>{editMode ? "Режим просмотра" : "Режим редактирования"}</p>
                </TooltipContent>
              </Tooltip>
            )}
            {musicActive && canMusicify && (
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={onMusicify}
                  >
                    <Music className="w-4 h-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Музицировать</p>
                </TooltipContent>
              </Tooltip>
            )}
          </TooltipProvider>
        </div>
      ) : null}

      {/* Контент превью */}
      {editMode || (!canRender && !shouldShowSwagger) ? (
        <TextEditor fileName={activeFileObj?.name || "untitled"} initialContent={fileContent} />
      ) : shouldShowSwagger ? (
        <SwaggerViewer spec={fileContent} />
      ) : canRender ? (
        <div className="flex-1 overflow-y-auto">
          <div className="max-w-4xl mx-auto p-8">
          <h1 className="text-3xl font-bold text-primary mb-6">
            Техническое задание: Трекер привычек
          </h1>
          
          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">1. Введение</h2>
            <p className="text-foreground leading-relaxed mb-4">
              Разрабатываемое приложение представляет собой мобильный трекер привычек, 
              позволяющий пользователям отслеживать формирование новых привычек и контролировать 
              выполнение ежедневных задач.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">2. Основные функции</h2>
            <ul className="list-disc list-inside space-y-2 text-foreground">
              <li>Создание и управление привычками</li>
              <li>Ежедневное отслеживание выполнения</li>
              <li>Визуализация прогресса в виде графиков и статистики</li>
              <li>Настройка напоминаний</li>
              <li>Система мотивационных достижений</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">3. Технические требования</h2>
            <table className="w-full border border-border rounded-lg overflow-hidden">
              <thead className="bg-muted">
                <tr>
                  <th className="px-4 py-3 text-left font-semibold">Компонент</th>
                  <th className="px-4 py-3 text-left font-semibold">Технология</th>
                </tr>
              </thead>
              <tbody>
                <tr className="border-t border-border">
                  <td className="px-4 py-3">Frontend</td>
                  <td className="px-4 py-3">React Native</td>
                </tr>
                <tr className="border-t border-border">
                  <td className="px-4 py-3">Backend</td>
                  <td className="px-4 py-3">Node.js + Express</td>
                </tr>
                <tr className="border-t border-border">
                  <td className="px-4 py-3">База данных</td>
                  <td className="px-4 py-3">PostgreSQL</td>
                </tr>
              </tbody>
            </table>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">4. Пользовательские истории</h2>
            <div className="bg-muted p-4 rounded-lg border-l-4 border-primary">
              <p className="font-medium mb-2">История 1: Создание привычки</p>
              <p className="text-sm text-muted-foreground">
                Как пользователь, я хочу создать новую привычку с названием, описанием и частотой выполнения, 
                чтобы начать её отслеживание.
              </p>
            </div>
          </section>

          {/* Пример диаграммы PlantUML */}
          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">5. Архитектура системы</h2>
            <Alert className="bg-muted border-l-4 border-yellow-500">
              <AlertDescription>
                <div className="mb-2 font-medium text-yellow-600 dark:text-yellow-400">
                  PlantUML пока не поддерживается
                </div>
                <pre className="text-xs text-muted-foreground overflow-x-auto p-2 bg-background rounded">
{`@startuml
actor User
participant "Mobile App" as App
participant "Backend API" as API
database "PostgreSQL" as DB

User -> App: Создать привычку
App -> API: POST /habits
API -> DB: INSERT habit
DB --> API: Success
API --> App: Habit created
App --> User: Показать подтверждение
@enduml`}
                </pre>
              </AlertDescription>
            </Alert>
          </section>

          {/* Пример диаграммы Mermaid */}
          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">6. Поток данных</h2>
            <Alert className="bg-muted border-l-4 border-yellow-500">
              <AlertDescription>
                <div className="mb-2 font-medium text-yellow-600 dark:text-yellow-400">
                  Mermaid пока не поддерживается
                </div>
                <pre className="text-xs text-muted-foreground overflow-x-auto p-2 bg-background rounded">
{`graph TD
    A[Пользователь] --> B[Мобильное приложение]
    B --> C{Тип действия}
    C -->|Создание| D[API: POST /habits]
    C -->|Просмотр| E[API: GET /habits]
    C -->|Обновление| F[API: PUT /habits/:id]
    D --> G[База данных]
    E --> G
    F --> G
    G --> H[Ответ пользователю]`}
                </pre>
              </AlertDescription>
            </Alert>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold mb-4">7. Критерии приёмки</h2>
            <div className="bg-card p-4 rounded-lg border border-border">
              <pre className="text-sm text-foreground overflow-x-auto">
                <code>{`Given пользователь находится на экране создания привычки
When пользователь вводит название и описание
And выбирает частоту выполнения
Then привычка создается и отображается в списке`}</code>
              </pre>
            </div>
          </section>
          </div>
        </div>
      ) : null}
    </div>
  );
};
