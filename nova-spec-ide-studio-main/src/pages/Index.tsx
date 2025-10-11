import { TopBar } from "@/components/TopBar";
import { FileExplorer } from "@/components/FileExplorer";
import { SpecPreview } from "@/components/SpecPreview";
import { AIAssistant } from "@/components/AIAssistant";
import { StatusBar, MusicificationStatus } from "@/components/StatusBar";
import { SettingsDialog } from "@/components/dialogs/SettingsDialog";
import { ErrorDialog } from "@/components/dialogs/ErrorDialog";
import { AboutDialog } from "@/components/dialogs/AboutDialog";
import { TemplatesDialog } from "@/components/dialogs/TemplatesDialog";
import { MusicifyDialog } from "@/components/dialogs/MusicifyDialog";
import { OnboardingDialog } from "@/components/dialogs/OnboardingDialog";
import { useState, useEffect } from "react";
import { toast } from "sonner";

const Index = () => {
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [errorOpen, setErrorOpen] = useState(false);
  const [aboutOpen, setAboutOpen] = useState(false);
  const [templatesOpen, setTemplatesOpen] = useState(false);
  const [musicifyOpen, setMusicifyOpen] = useState(false);
  const [onboardingOpen, setOnboardingOpen] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [musicBalance, setMusicBalance] = useState(1250);
  const [musicActive, setMusicActive] = useState(true);
  const [musicGenre, setMusicGenre] = useState("Поп");
  const [activeFile, setActiveFile] = useState("/api_openapi.json");
  const [openFiles, setOpenFiles] = useState([
    { name: "spec_v1.md", path: "/spec_v1.md", type: "md" },
    { name: "spec_v2.html", path: "/spec_v2.html", type: "html" },
    { name: "api_openapi.json", path: "/api_openapi.json", type: "json" },
    { name: "api_openapi.yaml", path: "/api_openapi.yaml", type: "yaml" },
    { name: "config.json", path: "/config.json", type: "json" },
    { name: "config.yaml", path: "/config.yaml", type: "yaml" },
  ]);
  const [musicificationStatus, setMusicificationStatus] = useState<MusicificationStatus>("idle");

  useEffect(() => {
    const hasSeenOnboarding = localStorage.getItem("novaspec_onboarding_completed");
    if (!hasSeenOnboarding) {
      setOnboardingOpen(true);
    }
  }, []);

  const handleOnboardingClose = (open: boolean) => {
    setOnboardingOpen(open);
    if (!open) {
      localStorage.setItem("novaspec_onboarding_completed", "true");
    }
  };

  const handleDebugOnboarding = () => {
    localStorage.removeItem("novaspec_onboarding_completed");
    setOnboardingOpen(true);
  };

  const handleShowError = (message: string) => {
    setErrorMessage(message);
    setErrorOpen(true);
  };

  const handleRefreshBalance = () => {
    toast.success("Баланс обновлен");
    setMusicBalance(Math.floor(Math.random() * 2000) + 500);
  };

  const handleMusicify = () => {
    setMusicifyOpen(true);
  };

  const handleMusicifyConfirm = () => {
    setMusicifyOpen(false);
    setMusicificationStatus("lyrics");
    
    setTimeout(() => {
      setMusicificationStatus("suno");
      setTimeout(() => {
        setMusicificationStatus("success");
        
        // Добавляем сгенерированный MP3 файл в проект
        const trackId = Math.floor(Math.random() * 100000);
        const newFile = { 
          name: `${trackId}.mp3`, 
          path: `/${trackId}.mp3`, 
          type: "mp3" 
        };
        setOpenFiles(prev => [...prev, newFile]);
        
        toast.success(`Трек ${trackId}.mp3 сохранен в проект`);
        
        setTimeout(() => {
          setMusicificationStatus("idle");
        }, 10000);
      }, 3000);
    }, 3000);
  };

  return (
    <div className="h-screen flex flex-col overflow-hidden bg-background text-foreground">
      <TopBar
        onOpenSettings={() => setSettingsOpen(true)}
        onOpenAbout={() => setAboutOpen(true)}
        onOpenTemplates={() => setTemplatesOpen(true)}
        aiProvider="OpenAI Competitive"
        atlassianActive={false}
        musicActive={musicActive}
        musicBalance={musicBalance}
        musicGenre={musicGenre}
        onRefreshBalance={handleRefreshBalance}
      />

      <div className="flex-1 flex overflow-hidden">
        <FileExplorer />
        <SpecPreview 
          musicActive={musicActive}
          openFiles={openFiles}
          activeFile={activeFile}
          onFileChange={setActiveFile}
          onMusicify={handleMusicify}
        />
        <AIAssistant />
      </div>

      <StatusBar 
        musicificationStatus={musicificationStatus}
        onDebugOnboarding={handleDebugOnboarding}
      />

      <SettingsDialog
        open={settingsOpen}
        onOpenChange={setSettingsOpen}
        onShowError={handleShowError}
        onGenreChange={setMusicGenre}
      />

      <ErrorDialog open={errorOpen} onOpenChange={setErrorOpen} errorMessage={errorMessage} />

      <AboutDialog open={aboutOpen} onOpenChange={setAboutOpen} />

      <TemplatesDialog open={templatesOpen} onOpenChange={setTemplatesOpen} />

      <MusicifyDialog 
        open={musicifyOpen} 
        onOpenChange={setMusicifyOpen}
        onConfirm={handleMusicifyConfirm}
      />

      <OnboardingDialog 
        open={onboardingOpen} 
        onOpenChange={handleOnboardingClose}
        onOpenSettings={() => setSettingsOpen(true)}
      />
    </div>
  );
};

export default Index;
