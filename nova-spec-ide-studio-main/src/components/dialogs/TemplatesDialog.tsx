import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, Pencil } from "lucide-react";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { useState } from "react";
import { AddTemplateTypeDialog } from "./AddTemplateTypeDialog";
import { AddTemplateDialog } from "./AddTemplateDialog";

interface TemplatesDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const defaultTemplateTypes = ["Техническое задание", "Функциональная документация"];

export const TemplatesDialog = ({ open, onOpenChange }: TemplatesDialogProps) => {
  const [selectedType, setSelectedType] = useState("Техническое задание");
  const [selectedTemplate, setSelectedTemplate] = useState("User Story One Page");
  const [templateTypes, setTemplateTypes] = useState(defaultTemplateTypes);
  const [addTypeDialogOpen, setAddTypeDialogOpen] = useState(false);
  const [addTemplateDialogOpen, setAddTemplateDialogOpen] = useState(false);
  const [editTypeDialogOpen, setEditTypeDialogOpen] = useState(false);
  const [editTemplateDialogOpen, setEditTemplateDialogOpen] = useState(false);

  const templates = {
    "Техническое задание": ["User Story One Page"],
    "Функциональная документация": ["Бизнес-ориентированная документация функционала"],
  };

  const canDeleteType = !defaultTemplateTypes.includes(selectedType);

  const handleAddType = (name: string) => {
    setTemplateTypes([...templateTypes, name]);
  };

  const handleEditType = (oldName: string, newName: string) => {
    setTemplateTypes(templateTypes.map(t => t === oldName ? newName : t));
    setSelectedType(newName);
  };

  const handleDeleteType = () => {
    if (canDeleteType) {
      setTemplateTypes(templateTypes.filter((t) => t !== selectedType));
      setSelectedType(templateTypes[0]);
    }
  };

  return (
    <>
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Шаблоны</DialogTitle>
          </DialogHeader>

          <div className="space-y-6">
            {/* Template Type Selection */}
            <div className="space-y-2">
              <label className="text-sm font-medium">Тип шаблона</label>
              <div className="flex gap-2">
                <Select value={selectedType} onValueChange={setSelectedType}>
                  <SelectTrigger className="flex-1">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {templateTypes.map((type) => (
                      <SelectItem key={type} value={type}>
                        {type}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <TooltipProvider>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setAddTypeDialogOpen(true)}
                      >
                        <Plus className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Добавить новый тип шаблона</p>
                    </TooltipContent>
                  </Tooltip>

                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setEditTypeDialogOpen(true)}
                      >
                        <Pencil className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Редактировать тип шаблона</p>
                    </TooltipContent>
                  </Tooltip>

                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={handleDeleteType}
                        disabled={!canDeleteType}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>
                        {canDeleteType
                          ? "Удалить тип шаблона"
                          : "Нельзя удалить тип по умолчанию"}
                      </p>
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              </div>
            </div>

            {/* Template Selection */}
            <div className="space-y-2">
              <label className="text-sm font-medium">Шаблон</label>
              <div className="flex gap-2">
                <Select value={selectedTemplate} onValueChange={setSelectedTemplate}>
                  <SelectTrigger className="flex-1">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {templates[selectedType as keyof typeof templates]?.map((template) => (
                      <SelectItem key={template} value={template}>
                        {template}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <TooltipProvider>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setAddTemplateDialogOpen(true)}
                      >
                        <Plus className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Добавить новый шаблон</p>
                    </TooltipContent>
                  </Tooltip>

                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="icon"
                        onClick={() => setEditTemplateDialogOpen(true)}
                      >
                        <Pencil className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Редактировать шаблон</p>
                    </TooltipContent>
                  </Tooltip>

                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button variant="outline" size="icon">
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Удалить шаблон</p>
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              </div>
            </div>

            <Button onClick={() => onOpenChange(false)} className="w-full">
              Закрыть
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <AddTemplateTypeDialog
        open={addTypeDialogOpen}
        onOpenChange={setAddTypeDialogOpen}
        onAdd={handleAddType}
      />

      <AddTemplateTypeDialog
        open={editTypeDialogOpen}
        onOpenChange={setEditTypeDialogOpen}
        onAdd={handleAddType}
        initialName={selectedType}
        onEdit={handleEditType}
      />

      <AddTemplateDialog
        open={addTemplateDialogOpen}
        onOpenChange={setAddTemplateDialogOpen}
      />

      <AddTemplateDialog
        open={editTemplateDialogOpen}
        onOpenChange={setEditTemplateDialogOpen}
        initialName={selectedTemplate}
        initialContent="Текст шаблона будет здесь..."
      />
    </>
  );
};
