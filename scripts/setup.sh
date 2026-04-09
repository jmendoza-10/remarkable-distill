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

# 2. Check for uv
if ! command -v uv &>/dev/null; then
    echo "[2/3] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[2/3] uv already installed: $(uv --version)"
fi

# 3. Install remarkable-mcp dependencies
echo "[3/3] Installing remarkable-mcp dependencies..."
cd "$PROJECT_DIR/vendor/remarkable-mcp"
uv sync --all-extras

# 4. Create .env if missing
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo ""
    echo "Created .env from .env.example — edit it to set OUTPUT_DIR if desired."
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Connect your reMarkable via USB"
echo "  2. Enable Settings > Storage > USB web interface on the tablet"
echo "  3. Open this project in VS Code / Claude Code"
echo "  4. Ask Claude: \"process my latest reMarkable notes\""
