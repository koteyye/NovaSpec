import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState } from "react";
import { toast } from "sonner";

interface AddTemplateTypeDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAdd: (name: string) => void;
  initialName?: string;
  onEdit?: (oldName: string, newName: string) => void;
}

export const AddTemplateTypeDialog = ({
  open,
  onOpenChange,
  onAdd,
  initialName,
  onEdit,
}: AddTemplateTypeDialogProps) => {
  const [typeName, setTypeName] = useState(initialName || "");

  const handleSave = () => {
    if (typeName.trim()) {
      if (initialName && onEdit) {
        onEdit(initialName, typeName);
        toast.success("Тип шаблона обновлен");
      } else {
        onAdd(typeName);
        toast.success("Тип шаблона сохранен");
      }
      setTypeName("");
      onOpenChange(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>{initialName ? "Редактировать тип шаблона" : "Добавить тип шаблона"}</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="typeName">Название типа шаблона</Label>
            <Input
              id="typeName"
              value={typeName}
              onChange={(e) => setTypeName(e.target.value)}
              placeholder="Например: Архитектурная документация"
            />
          </div>

          <div className="flex gap-3">
            <Button variant="outline" onClick={() => onOpenChange(false)} className="flex-1">
              Отменить
            </Button>
            <Button onClick={handleSave} className="flex-1">
              Сохранить
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};
