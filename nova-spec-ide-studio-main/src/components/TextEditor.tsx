import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Save } from "lucide-react";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { useState } from "react";
import { toast } from "sonner";

interface TextEditorProps {
  fileName: string;
  initialContent?: string;
}

const mockJsonContent = `{
  "projectName": "Трекер привычек",
  "version": "1.0.0",
  "requirements": {
    "functional": [
      "Создание и управление привычками",
      "Ежедневное отслеживание выполнения",
      "Визуализация прогресса"
    ],
    "technical": {
      "frontend": "React Native",
      "backend": "Node.js + Express",
      "database": "PostgreSQL"
    },
    "deadlines": {
      "startDate": "2025-01-01",
      "endDate": "2025-04-01"
    }
  }
}`;

export const TextEditor = ({ fileName, initialContent = mockJsonContent }: TextEditorProps) => {
  const [content, setContent] = useState(initialContent);

  const handleSave = () => {
    toast.success(`Файл ${fileName} сохранен`);
  };

  return (
    <div className="flex-1 bg-background flex flex-col h-full">
      <div className="border-b border-border px-4 py-2 flex items-center justify-between">
        <span className="text-sm text-muted-foreground">{fileName}</span>
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button variant="ghost" size="icon" onClick={handleSave}>
                <Save className="w-4 h-4" />
              </Button>
            </TooltipTrigger>
            <TooltipContent>
              <p>Сохранить</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>
      <Textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        className="flex-1 rounded-none border-0 resize-none font-mono text-sm p-4 focus-visible:ring-0"
        placeholder="Начните вводить текст..."
      />
    </div>
  );
};
