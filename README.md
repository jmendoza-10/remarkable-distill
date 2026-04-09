# remarkable-distill

Pull handwritten notes from a reMarkable tablet, OCR via Claude, and output distilled Markdown files.

## Architecture

```
reMarkable tablet
    │ USB Web (http://10.11.99.1)
    ▼
remarkable-mcp (submodule)    ← MCP server: browse, read, OCR
    │ MCP protocol
    ▼
Claude Code                   ← distill + restructure
    │
    ▼
output/*.md                   ← clean Markdown (or Obsidian vault)
```

## Setup

### macOS / Linux

```bash
git clone --recurse-submodules git@github.com:jmendoza-10/remarkable-distill.git
cd remarkable-distill
./scripts/setup.sh
```

### Windows (PowerShell)

```powershell
git clone --recurse-submodules git@github.com:jmendoza-10/remarkable-distill.git
cd remarkable-distill
.\scripts\setup.ps1
```

### reMarkable tablet setup

1. Connect tablet to your computer via USB
2. On tablet: **Settings > Storage > USB web interface** → enable

## Claude Desktop Setup

Claude Desktop uses a separate MCP config. Edit your `claude_desktop_config.json`:

- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

Copy the contents of `claude-desktop-config.json` from this repo and replace
`/FULL/PATH/TO/remarkable-distill` with the actual absolute path to this repo.

> **Note:** Claude Desktop can fetch, OCR, and distill your notes, but it cannot write
> files to disk directly. It will output the distilled Markdown in the chat for you to
> copy. For the full end-to-end workflow (automatic file writing), use Claude Code.

## Usage

### Claude Code

Open this project in Claude Code, then:

```
> process my latest reMarkable notes
> distill notes from the "Work" folder
> sync all notes tagged "meeting"
```

Claude will fetch, OCR, distill, and write Markdown files to `output/`.

### Claude Desktop

Open a conversation with the remarkable MCP server enabled, then:

```
process my latest reMarkable notes
```

Claude will fetch, OCR, and distill the notes. Copy the output Markdown from the
chat into your notes app or Obsidian vault.

### Output to Obsidian

Set `OUTPUT_DIR` in `.env` to your vault path:

```bash
# macOS / Linux
OUTPUT_DIR=/path/to/obsidian-vault/reMarkable

# Windows
OUTPUT_DIR=C:\Users\you\Documents\obsidian-vault\reMarkable
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `OUTPUT_DIR` | `./output` | Where distilled Markdown files are written |
| `REMARKABLE_OCR_BACKEND` | `sampling` | OCR backend: `sampling` (Claude), `google`, `tesseract` |

## License

MIT
