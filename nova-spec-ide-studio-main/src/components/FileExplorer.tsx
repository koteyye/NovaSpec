import { File, Folder, ChevronRight, ChevronDown, FileText, FileJson, FileCode, Music, FileAudio } from "lucide-react";
import { useState } from "react";
import novaspecLogo from "@/assets/novaspec-logo.svg";

interface FileNode {
  name: string;
  type: "file" | "folder";
  children?: FileNode[];
}

const getFileIcon = (fileName: string) => {
  const extension = fileName.split('.').pop()?.toLowerCase();
  switch (extension) {
    case 'md':
      return <FileText className="w-4 h-4 text-blue-500" />;
    case 'html':
      return <FileCode className="w-4 h-4 text-orange-500" />;
    case 'json':
      return <FileJson className="w-4 h-4 text-yellow-500" />;
    case 'xml':
      return <FileCode className="w-4 h-4 text-green-500" />;
    case 'yaml':
    case 'yml':
      return <FileCode className="w-4 h-4 text-purple-500" />;
    case 'mp3':
      return <Music className="w-4 h-4 text-pink-500" />;
    case 'wav':
      return <FileAudio className="w-4 h-4 text-cyan-500" />;
    default:
      return <File className="w-4 h-4" />;
  }
};

const mockFiles: FileNode[] = [
  {
    name: "Проект: Трекер привычек",
    type: "folder",
    children: [
      { name: "spec_v1.md", type: "file" },
      { name: "spec_v2.html", type: "file" },
      {
        name: "assets",
        type: "folder",
        children: [
          { name: "logo.png", type: "file" },
          { name: "screenshots", type: "folder", children: [] },
        ],
      },
      { name: "requirements.json", type: "file" },
      { name: "background_music.mp3", type: "file" },
      { name: "notification.wav", type: "file" },
    ],
  },
];

const FileTreeItem = ({ node, depth = 0 }: { node: FileNode; depth?: number }) => {
  const [expanded, setExpanded] = useState(depth === 0);

  if (node.type === "file") {
    return (
      <div
        className="flex items-center gap-2 px-3 py-1.5 hover:bg-hover cursor-pointer rounded transition-colors"
        style={{ paddingLeft: `${depth * 16 + 12}px` }}
      >
        {getFileIcon(node.name)}
        <span className="text-sm truncate">{node.name}</span>
      </div>
    );
  }

  return (
    <div>
      <div
        className="flex items-center gap-2 px-3 py-1.5 hover:bg-hover cursor-pointer rounded transition-colors"
        style={{ paddingLeft: `${depth * 16 + 12}px` }}
        onClick={() => setExpanded(!expanded)}
      >
        {expanded ? (
          <ChevronDown className="w-4 h-4 text-muted-foreground flex-shrink-0" />
        ) : (
          <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0" />
        )}
        <Folder className="w-4 h-4 text-accent flex-shrink-0" />
        <span className="text-sm font-medium truncate">{node.name}</span>
      </div>
      {expanded && node.children && (
        <div>
          {node.children.map((child, idx) => (
            <FileTreeItem key={idx} node={child} depth={depth + 1} />
          ))}
        </div>
      )}
    </div>
  );
};

export const FileExplorer = () => {
  return (
    <div className="w-64 border-r border-border bg-panel h-full flex flex-col">
      <div className="p-4 border-b border-border flex items-center gap-2">
        <img src={novaspecLogo} alt="NovaSpec" className="w-6 h-6" />
        <h2 className="text-sm font-semibold text-foreground">NovaSpec</h2>
      </div>
      <div className="py-2 overflow-y-auto flex-1">
        {mockFiles.map((node, idx) => (
          <FileTreeItem key={idx} node={node} />
        ))}
      </div>
    </div>
  );
};
