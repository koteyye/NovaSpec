import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Send, Brain } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

interface AddTemplateDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initialName?: string;
  initialContent?: string;
}

const models = [
  "GPT-5",
  "GPT-5 Mini",
  "Claude 4 Opus",
  "Claude 4 Sonnet",
  "Gemini 2.5 Pro",
];

export const AddTemplateDialog = ({ open, onOpenChange, initialName, initialContent }: AddTemplateDialogProps) => {
  const [templateName, setTemplateName] = useState(initialName || "");
  const [templateContent, setTemplateContent] = useState(initialContent || "");
  const [selectedModel, setSelectedModel] = useState("GPT-5");
  const [reviewPassed, setReviewPassed] = useState(false);
  const [reviewMessages, setReviewMessages] = useState<Array<{ role: string; content: string }>>(
    []
  );

  const handleReview = () => {
    setReviewMessages([
      {
        role: "assistant",
        content:
          "Анализирую шаблон... Структура выглядит хорошо. Рекомендую добавить раздел с критериями приёмки и примерами использования.",
      },
    ]);
    setTimeout(() => {
      setReviewPassed(true);
      toast.success("Ревью пройдено. Теперь можно сохранить шаблон.");
    }, 1500);
  };

  const handleSave = () => {
    toast.success(initialName ? "Шаблон обновлен" : "Шаблон сохранен");
    onOpenChange(false);
  };

  const handleSaveWithoutReview = () => {
    toast.success(initialName ? "Шаблон обновлен без ревью" : "Шаблон сохранен без ревью");
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-6xl max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>{initialName ? "Редактировать шаблон" : "Добавить шаблон"}</DialogTitle>
        </DialogHeader>

        <div className="flex-1 flex gap-6 overflow-hidden">
          {/* Left side - Template form */}
          <div className="flex-1 space-y-4 overflow-y-auto pr-2">
            <div className="space-y-2">
              <Label htmlFor="templateName">Название шаблона</Label>
              <Input
                id="templateName"
                value={templateName}
                onChange={(e) => setTemplateName(e.target.value)}
                placeholder="Например: User Story Extended"
              />
            </div>

            <div className="space-y-2 flex-1">
              <Label htmlFor="templateContent">Контент шаблона</Label>
              <Textarea
                id="templateContent"
                value={templateContent}
                onChange={(e) => setTemplateContent(e.target.value)}
                placeholder="Введите текст шаблона..."
                className="min-h-[400px] font-mono text-sm"
              />
            </div>
          </div>

          {/* Right side - AI Review */}
          <div className="w-96 border-l border-border pl-6 flex flex-col">
            <h3 className="text-sm font-semibold mb-3">AI-ревью</h3>

            <div className="space-y-3 mb-4">
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

              <Button onClick={handleReview} className="w-full">
                <Send className="w-4 h-4 mr-2" />
                Отправить на ревью
              </Button>
            </div>

            <ScrollArea className="flex-1 border border-border rounded-lg p-4">
              {reviewMessages.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-full text-center text-muted-foreground">
                  <Brain className="w-12 h-12 mb-3 opacity-50" />
                  <p className="text-sm">
                    Отправьте шаблон на ревью, чтобы получить рекомендации от AI
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {reviewMessages.map((message, idx) => (
                    <div key={idx} className="flex gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                        <Brain className="w-4 h-4 text-primary-foreground" />
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-sm flex-1">
                        {message.content}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </ScrollArea>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex gap-3 pt-4 border-t border-border">
          <Button onClick={handleSave} disabled={!reviewPassed} className="flex-1">
            Сохранить
          </Button>
          <Button onClick={handleSaveWithoutReview} variant="outline" className="flex-1">
            Сохранить без ревью
          </Button>
          <Button onClick={() => onOpenChange(false)} variant="outline" className="flex-1">
            Отменить
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};
