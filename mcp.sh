#!/bin/zsh

# Location of the mcptools command
MCPTOOLS_CMD="/opt/homebrew/bin/mcptools"

# MCP server URL
MCP_SERVER_URL="http://127.0.0.1:7860/gradio_api/mcp/sse"

# Check if bio parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <player_bio>"
    exit 1
fi

# Construct JSON with the bio parameter
PLAYER_BIO="$1"
JSON_PARAMS="{\"player_bio\":\"$PLAYER_BIO\"}"

# Execute the mcptools command
"$MCPTOOLS_CMD" call generate_3d_assets --params "$JSON_PARAMS" "$MCP_SERVER_URL"