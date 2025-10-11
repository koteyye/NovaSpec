import SwaggerUI from "swagger-ui-react";
import "swagger-ui-react/swagger-ui.css";

interface SwaggerViewerProps {
  spec: string;
}

export const SwaggerViewer = ({ spec }: SwaggerViewerProps) => {
  let parsedSpec;
  
  try {
    // Try to parse as JSON first
    parsedSpec = JSON.parse(spec);
  } catch {
    // If it fails, assume it's YAML and pass as string
    parsedSpec = spec;
  }

  return (
    <div className="swagger-container h-full overflow-y-auto">
      <SwaggerUI spec={parsedSpec} />
    </div>
  );
};