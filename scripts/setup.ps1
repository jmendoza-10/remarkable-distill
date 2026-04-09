# Setup script for remarkable-distill (Windows)
# Installs dependencies and initializes the submodule

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "=== remarkable-distill setup ==="

# 1. Init submodule
Write-Host "[1/3] Initializing remarkable-mcp submodule..."
Push-Location $ProjectDir
git submodule update --init --recursive

# 2. Check for uv
Write-Host "[2/3] Checking for uv..."
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
} else {
    $uvVersion = uv --version
    Write-Host "uv already installed: $uvVersion"
}

# 3. Install remarkable-mcp dependencies
Write-Host "[3/3] Installing remarkable-mcp dependencies..."
Push-Location "$ProjectDir\vendor\remarkable-mcp"
uv sync --all-extras
Pop-Location

# 4. Create .env if missing
if (-not (Test-Path "$ProjectDir\.env")) {
    Copy-Item "$ProjectDir\.env.example" "$ProjectDir\.env"
    Write-Host ""
    Write-Host "Created .env from .env.example - edit it to set OUTPUT_DIR if desired."
}

Pop-Location

# 5. Generate ready-to-use Claude Desktop config
$template = Get-Content "$ProjectDir\claude-desktop-config.json" -Raw
$localConfig = $template -replace '/FULL/PATH/TO/remarkable-distill', ($ProjectDir -replace '\\', '/')
$localConfigPath = "$ProjectDir\.claude-desktop-config-local.json"
Set-Content -Path $localConfigPath -Value $localConfig

Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Connect your reMarkable via USB"
Write-Host "  2. Enable Settings > Storage > USB web interface on the tablet"
Write-Host ""
Write-Host "  Option A - Claude Code / VS Code:"
Write-Host "    3. Open this project in Claude Code or VS Code"
Write-Host '    4. Ask Claude: "process my latest reMarkable notes"'
Write-Host "       (MCP config is already set in .vscode/mcp.json)"
Write-Host ""
Write-Host "  Option B - Claude Desktop:"
Write-Host "    3. In Claude Desktop: Settings (gear icon) > Developer > Edit Config"
Write-Host "    4. Paste the following into the config file that opens:"
Write-Host ""
Write-Host $localConfig
Write-Host ""
Write-Host "    5. Save the file and restart Claude Desktop."
