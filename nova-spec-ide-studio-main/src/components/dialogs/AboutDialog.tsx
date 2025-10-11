import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Brain } from "lucide-react";

interface AboutDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export const AboutDialog = ({ open, onOpenChange }: AboutDialogProps) => {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
              <Brain className="w-6 h-6 text-primary" />
            </div>
            <DialogTitle>О программе</DialogTitle>
          </div>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-2">
            <h3 className="font-semibold text-lg">NovaSpec</h3>
            <p className="text-sm text-muted-foreground">
              Профессиональный инструмент для совместной выработки технических заданий с ИИ-ассистентом. 
              Превращает идеи в структурированную документацию.
            </p>
          </div>

          <div className="border-t border-border pt-4 space-y-1">
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">Версия:</span>
              <span className="font-medium">1.0.0</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">Создатель:</span>
              <span className="font-medium">Koteyye</span>
            </div>
          </div>

          <Button onClick={() => onOpenChange(false)} className="w-full">
            Закрыть
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};
