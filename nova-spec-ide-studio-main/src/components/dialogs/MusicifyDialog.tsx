import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Check, X } from "lucide-react";

interface MusicifyDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: () => void;
}

export const MusicifyDialog = ({ open, onOpenChange, onConfirm }: MusicifyDialogProps) => {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Музицировать документ</AlertDialogTitle>
          <AlertDialogDescription className="space-y-3">
            <p>
              На основе вашего документа будет сгенерирована музыкальная композиция с помощью нейросети Suno v5.
            </p>
            <p>
              Данная операция расходует средства с баланса genAPI (~14₽) и вряд ли понадобится вам в работе.
            </p>
            <p className="font-medium text-foreground">
              Вы уверены, что хотите музицировать документ?
            </p>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel className="gap-2">
            <X className="w-4 h-4" />
            Нет
          </AlertDialogCancel>
          <AlertDialogAction onClick={onConfirm} className="gap-2">
            <Check className="w-4 h-4" />
            Да
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
