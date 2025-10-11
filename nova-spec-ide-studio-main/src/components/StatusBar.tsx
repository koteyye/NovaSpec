import { Sun, Moon, Bug } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";

export type MusicificationStatus = "idle" | "lyrics" | "suno" | "success";

interface StatusBarProps {
  musicificationStatus?: MusicificationStatus;
  onDebugOnboarding?: () => void;
}

export const StatusBar = ({ musicificationStatus = "idle", onDebugOnboarding }: StatusBarProps) => {
  const [theme, setTheme] = useState<"light" | "dark">("light");
  
  const getStatusText = () => {
    switch (musicificationStatus) {
      case "lyrics":
        return "Генерирую Lyrics";
      case "suno":
        return "Отправил документ в Suno";
      case "success":
        return "Музикация успешно выполнена";
      default:
        return "Готов";
    }
  };

  useEffect(() => {
    const root = window.document.documentElement;
    root.classList.remove("light", "dark");
    root.classList.add(theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : "light");
  };

  return (
    <div className="h-8 border-t border-border bg-statusbar flex items-center justify-between px-4 text-xs">
      <div className="flex items-center gap-4">
        <span className="text-muted-foreground">spec_v2.md</span>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div className={`w-2 h-2 rounded-full ${
            musicificationStatus === "idle" ? "bg-green-500" : 
            musicificationStatus === "success" ? "bg-green-500" : 
            "bg-yellow-500 animate-pulse"
          }`}></div>
          <span className="text-muted-foreground">{getStatusText()}</span>
        </div>
      </div>

      <div className="flex items-center gap-2">
        {onDebugOnboarding && (
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={onDebugOnboarding} 
            className="h-6 px-2"
            title="Debug: Показать онбординг"
          >
            <Bug className="w-3 h-3 mr-1" />
            <span className="text-xs">Онбординг</span>
          </Button>
        )}
        <Button variant="ghost" size="sm" onClick={toggleTheme} className="h-6 w-6 p-0">
          {theme === "light" ? <Moon className="w-3 h-3" /> : <Sun className="w-3 h-3" />}
        </Button>
      </div>
    </div>
  );
};
