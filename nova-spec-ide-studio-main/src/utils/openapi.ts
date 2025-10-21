// Utility to check if a file content is an OpenAPI specification
export const isOpenAPISpec = (content: string): boolean => {
  try {
    const parsed = JSON.parse(content);
    
    // Check for OpenAPI 3.x
    if (parsed.openapi && typeof parsed.openapi === 'string' && parsed.openapi.startsWith('3.')) {
      return !!(parsed.info && parsed.paths);
    }
    
    // Check for Swagger 2.0
    if (parsed.swagger && parsed.swagger === '2.0') {
      return !!(parsed.info && parsed.paths);
    }
    
    return false;
  } catch {
    // If JSON parsing fails, try YAML detection
    const lines = content.split('\n');
    const hasOpenAPI = lines.some(line => 
      line.trim().startsWith('openapi:') && line.includes('3.')
    );
    const hasSwagger = lines.some(line => 
      line.trim().startsWith('swagger:') && line.includes('2.0')
    );
    const hasInfo = lines.some(line => line.trim().startsWith('info:'));
    const hasPaths = lines.some(line => line.trim().startsWith('paths:'));
    
    return (hasOpenAPI || hasSwagger) && hasInfo && hasPaths;
  }
};

// Mock OpenAPI specifications
export const mockOpenAPIJson = `{
  "openapi": "3.0.0",
  "info": {
    "title": "Habit Tracker API",
    "version": "1.0.0",
    "description": "API для управления привычками"
  },
  "servers": [
    {
      "url": "https://api.habittracker.com/v1"
    }
  ],
  "paths": {
    "/habits": {
      "get": {
        "summary": "Получить список привычек",
        "responses": {
          "200": {
            "description": "Успешный ответ",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": {
                    "$ref": "#/components/schemas/Habit"
                  }
                }
              }
            }
          }
        }
      },
      "post": {
        "summary": "Создать новую привычку",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/HabitInput"
              }
            }
          }
        },
        "responses": {
          "201": {
            "description": "Привычка создана"
          }
        }
      }
    },
    "/habits/{id}": {
      "get": {
        "summary": "Получить привычку по ID",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Успешный ответ"
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "Habit": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string"
          },
          "name": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "frequency": {
            "type": "string"
          }
        }
      },
      "HabitInput": {
        "type": "object",
        "required": ["name", "frequency"],
        "properties": {
          "name": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "frequency": {
            "type": "string"
          }
        }
      }
    }
  }
}`;

export const mockOpenAPIYaml = `openapi: 3.0.0
info:
  title: Habit Tracker API
  version: 1.0.0
  description: API для управления привычками
servers:
  - url: https://api.habittracker.com/v1
paths:
  /habits:
    get:
      summary: Получить список привычек
      responses:
        '200':
          description: Успешный ответ
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Habit'
    post:
      summary: Создать новую привычку
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/HabitInput'
      responses:
        '201':
          description: Привычка создана
  /habits/{id}:
    get:
      summary: Получить привычку по ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Успешный ответ
components:
  schemas:
    Habit:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        description:
          type: string
        frequency:
          type: string
    HabitInput:
      type: object
      required:
        - name
        - frequency
      properties:
        name:
          type: string
        description:
          type: string
        frequency:
          type: string`;

export const mockRegularJson = `{
  "projectName": "Трекер привычек",
  "version": "1.0.0",
  "requirements": {
    "functional": [
      "Создание и управление привычками",
      "Ежедневное отслеживание выполнения",
      "Визуализация прогресса"
    ],
    "technical": {
      "frontend": "React Native",
      "backend": "Node.js + Express",
      "database": "PostgreSQL"
    }
  }
}`;

export const mockRegularYaml = `projectName: Трекер привычек
version: 1.0.0
requirements:
  functional:
    - Создание и управление привычками
    - Ежедневное отслеживание выполнения
    - Визуализация прогресса
  technical:
    frontend: React Native
    backend: Node.js + Express
    database: PostgreSQL`;