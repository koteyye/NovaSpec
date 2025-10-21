import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { AlertCircle, Copy } from "lucide-react";
import { toast } from "sonner";

interface ErrorDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  errorMessage: string;
}

export const ErrorDialog = ({ open, onOpenChange, errorMessage }: ErrorDialogProps) => {
  const handleCopy = () => {
    navigator.clipboard.writeText(errorMessage);
    toast.success("Текст ошибки скопирован в буфер обмена");
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-destructive/10 flex items-center justify-center">
              <AlertCircle className="w-6 h-6 text-destructive" />
            </div>
            <DialogTitle>Ошибка</DialogTitle>
          </div>
        </DialogHeader>

        <div className="space-y-4">
          <div className="bg-muted p-4 rounded-lg border border-border relative group">
            <p className="text-sm text-foreground pr-8">{errorMessage}</p>
            <Button
              variant="ghost"
              size="icon"
              className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity"
              onClick={handleCopy}
            >
              <Copy className="w-4 h-4" />
            </Button>
          </div>

          <Button onClick={() => onOpenChange(false)} className="w-full">
            Закрыть
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};
