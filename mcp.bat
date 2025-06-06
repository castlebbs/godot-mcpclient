@echo off

REM Configuration
set "MCPTOOLS_CMD=mcptools"
set "MCP_SERVER_URL=http://127.0.0.1:7860/gradio_api/mcp/sse"

REM Check if bio parameter is provided
if "%~1"=="" (
    echo Usage: %0 ^<player_bio^>
    exit /b 1
)

REM Construct JSON with the bio parameter
set "PLAYER_BIO=%~1"
set "JSON_PARAMS={\"player_bio\":\"%PLAYER_BIO%\"}"

REM Execute the mcptools command
%MCPTOOLS_CMD% call generate_3d_assets --params "%JSON_PARAMS%" "%MCP_SERVER_URL%"