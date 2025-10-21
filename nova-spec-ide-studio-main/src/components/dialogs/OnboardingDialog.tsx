import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { FileText, FolderOpen, Folder } from "lucide-react";
import { useState, useRef } from "react";

interface OnboardingDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onOpenSettings: () => void;
}

export const OnboardingDialog = ({ open, onOpenChange, onOpenSettings }: OnboardingDialogProps) => {
  const [step, setStep] = useState<"project" | "new-project-setup" | "settings">("project");
  const [projectName, setProjectName] = useState("");
  const [projectPath, setProjectPath] = useState("");
  const folderInputRef = useRef<HTMLInputElement>(null);

  const handleCreateNew = () => {
    setStep("new-project-setup");
  };

  const handleOpenExisting = () => {
    setStep("settings");
  };

  const handleBrowseFolder = () => {
    folderInputRef.current?.click();
  };

  const handleFolderChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (files && files.length > 0) {
      const path = files[0].webkitRelativePath.split('/')[0];
      setProjectPath(path);
    }
  };

  const handleContinueToSettings = () => {
    if (projectName && projectPath) {
      setStep("settings");
    }
  };

  const handleSkip = () => {
    onOpenChange(false);
    setStep("project");
    setProjectName("");
    setProjectPath("");
  };

  const handleConfigure = () => {
    onOpenChange(false);
    setStep("project");
    setProjectName("");
    setProjectPath("");
    onOpenSettings();
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        {step === "project" ? (
          <>
            <DialogHeader>
              <DialogTitle className="text-2xl">Добро пожаловать в NovaSpec</DialogTitle>
              <DialogDescription className="text-base pt-2">
                Создайте новый проект или откройте существующий, чтобы начать работу
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-6">
              <Button
                variant="outline"
                className="h-24 flex flex-col gap-2 hover:bg-accent"
                onClick={handleCreateNew}
              >
                <FileText className="h-8 w-8" />
                <span className="text-base font-semibold">Создать новый проект</span>
              </Button>
              <Button
                variant="outline"
                className="h-24 flex flex-col gap-2 hover:bg-accent"
                onClick={handleOpenExisting}
              >
                <FolderOpen className="h-8 w-8" />
                <span className="text-base font-semibold">Открыть существующий проект</span>
              </Button>
            </div>
          </>
        ) : step === "new-project-setup" ? (
          <>
            <DialogHeader>
              <DialogTitle className="text-2xl">Создание нового проекта</DialogTitle>
              <DialogDescription className="text-base pt-2">
                Укажите имя проекта и выберите папку для сохранения
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-6">
              <div className="grid gap-2">
                <Label htmlFor="project-name">Имя проекта</Label>
                <Input
                  id="project-name"
                  placeholder="Мой проект"
                  value={projectName}
                  onChange={(e) => setProjectName(e.target.value)}
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="project-path">Путь к папке</Label>
                <div className="flex gap-2">
                  <Input
                    id="project-path"
                    placeholder="Выберите папку..."
                    value={projectPath}
                    readOnly
                    className="flex-1"
                  />
                  <Button
                    variant="outline"
                    onClick={handleBrowseFolder}
                    className="shrink-0"
                  >
                    <Folder className="h-4 w-4 mr-2" />
                    Обзор
                  </Button>
                </div>
                <input
                  ref={folderInputRef}
                  type="file"
                  className="hidden"
                  onChange={handleFolderChange}
                  {...({ webkitdirectory: "", directory: "" } as any)}
                />
              </div>
            </div>
            <DialogFooter className="flex gap-2 sm:gap-2">
              <Button variant="outline" onClick={() => setStep("project")}>
                Назад
              </Button>
              <Button 
                onClick={handleContinueToSettings}
                disabled={!projectName || !projectPath}
              >
                Продолжить
              </Button>
            </DialogFooter>
          </>
        ) : (
          <>
            <DialogHeader>
              <DialogTitle className="text-2xl">Настройка ИИ и интеграций</DialogTitle>
              <DialogDescription className="text-base pt-2">
                Настройте AI-провайдера и интеграции для полноценной работы с приложением
              </DialogDescription>
            </DialogHeader>
            <div className="py-6">
              <p className="text-sm text-muted-foreground">
                Вы можете настроить параметры прямо сейчас или сделать это позже в настройках приложения.
              </p>
            </div>
            <DialogFooter className="flex gap-2 sm:gap-2">
              <Button variant="outline" onClick={handleSkip}>
                Пропустить
              </Button>
              <Button onClick={handleConfigure}>
                Настроить
              </Button>
            </DialogFooter>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
};
