import { Menubar, MenubarContent, MenubarItem, MenubarMenu, MenubarTrigger } from "@/components/ui/menubar";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Brain, Music, RefreshCw } from "lucide-react";
import atlassianIcon from "@/assets/atlassian-icon.svg";
import { useState } from "react";

interface TopBarProps {
  onOpenSettings: () => void;
  onOpenAbout: () => void;
  onOpenTemplates: () => void;
  aiProvider: string;
  atlassianActive: boolean;
  musicActive: boolean;
  musicBalance: number;
  musicGenre: string;
  onRefreshBalance: () => void;
}

export const TopBar = ({
  onOpenSettings,
  onOpenAbout,
  onOpenTemplates,
  aiProvider,
  atlassianActive,
  musicActive,
  musicBalance,
  musicGenre,
  onRefreshBalance,
}: TopBarProps) => {
  return (
    <div className="h-12 border-b border-border bg-panel flex items-center justify-between px-4">
      <Menubar className="border-none bg-transparent">
        <MenubarMenu>
          <MenubarTrigger className="cursor-pointer">Файл</MenubarTrigger>
          <MenubarContent>
            <MenubarItem>
              Новый проект <span className="ml-auto text-xs text-muted-foreground">Ctrl+N</span>
            </MenubarItem>
            <MenubarItem>
              Открыть проект <span className="ml-auto text-xs text-muted-foreground">Ctrl+O</span>
            </MenubarItem>
            <MenubarItem>Сохранить</MenubarItem>
            <MenubarItem>Сохранить как...</MenubarItem>
          </MenubarContent>
        </MenubarMenu>

        <MenubarMenu>
          <MenubarTrigger className="cursor-pointer">Настройки</MenubarTrigger>
          <MenubarContent>
            <MenubarItem onClick={onOpenSettings}>
              Параметры <span className="ml-auto text-xs text-muted-foreground">Ctrl+,</span>
            </MenubarItem>
            <MenubarItem onClick={onOpenTemplates}>Шаблоны</MenubarItem>
          </MenubarContent>
        </MenubarMenu>

        <MenubarMenu>
          <MenubarTrigger className="cursor-pointer" onClick={onOpenAbout}>
            О программе
          </MenubarTrigger>
        </MenubarMenu>
      </Menubar>

      <TooltipProvider>
        <div className="flex items-center gap-2">
          {/* AI Provider Indicator */}
          <Tooltip>
            <TooltipTrigger asChild>
              <div className="flex items-center gap-2 px-3 py-1.5 border border-border rounded-lg">
                <Brain
                  className="w-4 h-4"
                  style={{ color: aiProvider ? "hsl(var(--indicator-active))" : "hsl(var(--indicator-inactive))" }}
                />
                {aiProvider && <span className="text-sm">{aiProvider}</span>}
              </div>
            </TooltipTrigger>
            <TooltipContent>
              <p>AI-провайдер</p>
            </TooltipContent>
          </Tooltip>

          {/* Atlassian Indicator */}
          <Tooltip>
            <TooltipTrigger asChild>
              <div className="flex items-center gap-2 px-3 py-1.5 border border-border rounded-lg">
                <img
                  src={atlassianIcon}
                  alt="Atlassian"
                  className="w-4 h-4"
                  style={{
                    filter: atlassianActive ? "none" : "grayscale(100%)",
                  }}
                />
              </div>
            </TooltipTrigger>
            <TooltipContent>
              <p>Интеграция с Confluence</p>
            </TooltipContent>
          </Tooltip>

          {/* Music Indicator */}
          <Tooltip>
            <TooltipTrigger asChild>
              <div className="flex items-center gap-2 px-3 py-1.5 border border-border rounded-lg">
                <Music
                  className="w-4 h-4"
                  style={{ color: musicActive ? "hsl(var(--indicator-active))" : "hsl(var(--indicator-inactive))" }}
                />
                {musicActive && (
                  <>
                    <span className="text-sm">{musicBalance} ₽</span>
                    <span className="text-sm text-muted-foreground">·</span>
                    <span className="text-sm">{musicGenre}</span>
                    <button
                      onClick={onRefreshBalance}
                      className="p-0.5 hover:bg-hover rounded transition-colors"
                    >
                      <RefreshCw className="w-3 h-3" />
                    </button>
                  </>
                )}
              </div>
            </TooltipTrigger>
            <TooltipContent>
              <p>Музикация</p>
            </TooltipContent>
          </Tooltip>
        </div>
      </TooltipProvider>
    </div>
  );
};
