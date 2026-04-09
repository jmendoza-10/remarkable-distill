#!/usr/bin/env bash
set -euo pipefail

# Setup script for remarkable-distill
# Installs dependencies and initializes the submodule

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== remarkable-distill setup ==="

# 1. Init submodule
echo "[1/3] Initializing remarkable-mcp submodule..."
cd "$PROJECT_DIR"
git submodule update --init --recursive

# 2. Install system dependencies
echo "[2/4] Installing system dependencies..."
if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "  Homebrew not found — install it from https://brew.sh"
    else
        if ! brew list cairo &>/dev/null 2>&1; then
            echo "  Installing cairo (required for rendering notebook pages)..."
            brew install cairo
        else
            echo "  cairo already installed"
        fi
    fi
elif command -v apt-get &>/dev/null; then
    echo "  Installing libcairo2-dev (required for rendering notebook pages)..."
    sudo apt-get install -y libcairo2-dev
fi

# 3. Check for uv
if ! command -v uv &>/dev/null; then
    echo "[3/4] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for the rest of this script
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "[3/4] uv already installed: $(uv --version)"
fi

# 4. Install remarkable-mcp dependencies
echo "[4/4] Installing remarkable-mcp dependencies..."
cd "$PROJECT_DIR/vendor/remarkable-mcp"
uv sync --all-extras

# 5. Create .env if missing
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo ""
    echo "Created .env from .env.example — edit it to set OUTPUT_DIR if desired."
fi

# 6. Resolve full path to uvx for Claude Desktop (it doesn't inherit shell PATH)
UVX_PATH="$(command -v uvx 2>/dev/null || echo "$HOME/.local/bin/uvx")"

# 7. Generate ready-to-use Claude Desktop config snippet
sed -e "s|/FULL/PATH/TO/remarkable-distill|$PROJECT_DIR|g" \
    -e "s|/FULL/PATH/TO/uvx|$UVX_PATH|g" \
    "$PROJECT_DIR/claude-desktop-config.json" > "$PROJECT_DIR/.claude-desktop-config-local.json"

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Connect your reMarkable via USB"
echo "  2. Enable Settings > Storage > USB web interface on the tablet"
echo ""
echo "  Option A — Claude Code / VS Code:"
echo "    3. Open this project in Claude Code or VS Code"
echo "    4. Ask Claude: \"process my latest reMarkable notes\""
echo "       (MCP config is already set in .vscode/mcp.json)"
echo ""
echo "  Option B — Claude Desktop:"
echo "    3. In Claude Desktop: Settings (gear icon) > Developer > Edit Config"
echo "       This opens your claude_desktop_config.json file."
echo ""
echo "    4. Add the \"remarkable\" server to the \"mcpServers\" section."
echo "       If the file already has content, MERGE — don't replace."
echo ""
echo "       If the file is empty or has only {}, paste this entire block:"
echo ""
cat "$PROJECT_DIR/.claude-desktop-config-local.json"
echo ""
echo "       If the file already has an \"mcpServers\" section, add just this"
echo "       entry inside it (after the opening brace, with a comma separator):"
echo ""
echo "        \"remarkable\": {"
echo "          \"command\": \"$UVX_PATH\","
echo "          \"args\": [\"--from\", \"$PROJECT_DIR/vendor/remarkable-mcp\", \"remarkable-mcp\", \"--usb\"],"
echo "          \"env\": { \"REMARKABLE_OCR_BACKEND\": \"sampling\" }"
echo "        }"
echo ""
echo "    5. Save the file and restart Claude Desktop."
