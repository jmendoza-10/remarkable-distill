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

```bash
git clone --recurse-submodules git@github.com:jmendoza-10/remarkable-distill.git
cd remarkable-distill
./scripts/setup.sh
```

### reMarkable tablet setup

1. Connect tablet to Mac via USB
2. On tablet: **Settings > Storage > USB web interface** → enable

## Usage

Open this project in Claude Code, then:

```
> process my latest reMarkable notes
> distill notes from the "Work" folder
> sync all notes tagged "meeting"
```

Claude will fetch, OCR, distill, and write Markdown files to `output/`.

### Output to Obsidian

Set `OUTPUT_DIR` in `.env` to your vault path:

```
OUTPUT_DIR=/path/to/obsidian-vault/reMarkable
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `OUTPUT_DIR` | `./output` | Where distilled Markdown files are written |
| `REMARKABLE_OCR_BACKEND` | `sampling` | OCR backend: `sampling` (Claude), `google`, `tesseract` |

## License

MIT
