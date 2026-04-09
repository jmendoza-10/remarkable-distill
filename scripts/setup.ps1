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

# 5. Resolve full path to uvx for Claude Desktop (it doesn't inherit shell PATH)
$UvxPath = (Get-Command uvx -ErrorAction SilentlyContinue).Source
if (-not $UvxPath) { $UvxPath = "$env:USERPROFILE\.local\bin\uvx.exe" }
$UvxPathForJson = $UvxPath -replace '\\', '/'

# 6. Generate ready-to-use Claude Desktop config snippet
$template = Get-Content "$ProjectDir\claude-desktop-config.json" -Raw
$ProjectDirForJson = $ProjectDir -replace '\\', '/'
$localConfig = $template -replace '/FULL/PATH/TO/remarkable-distill', $ProjectDirForJson
$localConfig = $localConfig -replace '/FULL/PATH/TO/uvx', $UvxPathForJson
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
Write-Host "       This opens your claude_desktop_config.json file."
Write-Host ""
Write-Host "    4. Add the 'remarkable' server to the 'mcpServers' section."
Write-Host "       If the file already has content, MERGE - don't replace."
Write-Host ""
Write-Host "       If the file is empty or has only {}, paste this entire block:"
Write-Host ""
Write-Host $localConfig
Write-Host ""
Write-Host "       If the file already has an 'mcpServers' section, add just this"
Write-Host "       entry inside it (after the opening brace, with a comma separator):"
Write-Host ""
Write-Host "        `"remarkable`": {"
Write-Host "          `"command`": `"$UvxPathForJson`","
Write-Host "          `"args`": [`"--from`", `"$ProjectDirForJson/vendor/remarkable-mcp`", `"remarkable-mcp`", `"--usb`"],"
Write-Host "          `"env`": { `"REMARKABLE_OCR_BACKEND`": `"sampling`" }"
Write-Host "        }"
Write-Host ""
Write-Host "    5. Save the file and restart Claude Desktop."
