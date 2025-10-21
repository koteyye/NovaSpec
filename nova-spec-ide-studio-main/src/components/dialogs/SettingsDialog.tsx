import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { useState } from "react";

interface SettingsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onShowError: (message: string) => void;
  onGenreChange?: (genre: string) => void;
}

const providers = [
  "OpenAI",
  "OpenAI Competitive",
  "Anthropic",
  "Cerebras",
  "Groq",
  "LM Studio",
  "Ollama",
  "OpenRouter",
];

const languages = ["Русский", "Английский"];

const musicGenres = [
  "Поп",
  "Русский рэп",
  "Рок",
  "Джаз",
  "Классика",
  "Электронная музыка",
  "Хип-хоп",
  "R&B",
];

export const SettingsDialog = ({ open, onOpenChange, onShowError, onGenreChange }: SettingsDialogProps) => {
  const [selectedProvider, setSelectedProvider] = useState("OpenAI");
  const [selectedLanguage, setSelectedLanguage] = useState("Русский");
  const [selectedGenre, setSelectedGenre] = useState("Поп");
  const [atlassianEnabled, setAtlassianEnabled] = useState(false);
  const [musicEnabled, setMusicEnabled] = useState(false);

  const handleCheck = () => {
    onShowError("Не удалось подключиться к провайдеру. Проверьте правильность введенных данных.");
  };

  const showProviderFields = () => {
    if (selectedProvider === "OpenAI Competitive") {
      return (
        <>
          <div className="space-y-2">
            <Label htmlFor="baseUrl">Базовый URL</Label>
            <Input id="baseUrl" placeholder="https://api.example.com" />
          </div>
          <div className="space-y-2">
            <Label htmlFor="token">Токен</Label>
            <Input id="token" type="password" placeholder="sk-..." />
          </div>
        </>
      );
    }

    if (selectedProvider === "LM Studio" || selectedProvider === "Ollama") {
      return (
        <>
          <div className="space-y-2">
            <Label htmlFor="baseUrl">Базовый URL</Label>
            <Input id="baseUrl" placeholder="http://localhost:1234" />
          </div>
          <div className="space-y-2">
            <Label htmlFor="token">Токен (опционально)</Label>
            <Input id="token" type="password" placeholder="Оставьте пустым, если не требуется" />
          </div>
        </>
      );
    }

    return (
      <div className="space-y-2">
        <Label htmlFor="token">Токен</Label>
        <Input id="token" type="password" placeholder="sk-..." />
      </div>
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-2xl">Параметры</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Provider Section */}
          <div className="space-y-4">
            <h3 className="text-base font-semibold">Провайдер</h3>
            <div className="space-y-2">
              <Label htmlFor="provider">Выберите провайдера</Label>
              <Select value={selectedProvider} onValueChange={setSelectedProvider}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {providers.map((provider) => (
                    <SelectItem key={provider} value={provider}>
                      {provider}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            {showProviderFields()}
          </div>

          {/* Atlassian Section */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-semibold">Интеграция с Confluence</h3>
              <Switch checked={atlassianEnabled} onCheckedChange={setAtlassianEnabled} />
            </div>
            {atlassianEnabled && (
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="atlassianBaseUrl">Базовый URL</Label>
                  <Input id="atlassianBaseUrl" placeholder="https://your-domain.atlassian.net" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="atlassianEmail">Email</Label>
                  <Input id="atlassianEmail" type="email" placeholder="user@example.com" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="atlassianToken">Токен</Label>
                  <Input id="atlassianToken" type="password" placeholder="Atlassian API Token" />
                </div>
              </div>
            )}
          </div>

          {/* Music Section */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-semibold">Музикация</h3>
              <Switch checked={musicEnabled} onCheckedChange={setMusicEnabled} />
            </div>
            {musicEnabled && (
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="musicToken">Токен</Label>
                  <Input id="musicToken" type="password" placeholder="Music API Token" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="musicGenre">Жанр</Label>
                  <Select value={selectedGenre} onValueChange={(value) => {
                    setSelectedGenre(value);
                    onGenreChange?.(value);
                  }}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {musicGenres.map((genre) => (
                        <SelectItem key={genre} value={genre}>
                          {genre}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <p className="text-sm text-muted-foreground">
                  Токен можно получить на{" "}
                  <a
                    href="https://gen-api.ru"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline"
                  >
                    gen-api.ru
                  </a>
                </p>
              </div>
            )}
          </div>

          {/* Language Section */}
          <div className="space-y-4">
            <h3 className="text-base font-semibold">Язык</h3>
            <div className="space-y-2">
              <Select value={selectedLanguage} onValueChange={setSelectedLanguage}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {languages.map((language) => (
                    <SelectItem key={language} value={language}>
                      {language}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4">
            <Button variant="outline" onClick={handleCheck}>
              Проверить
            </Button>
            <Button onClick={() => onOpenChange(false)}>Сохранить</Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};
