# remarkable-distill

## Overview

This repo provides a Claude Code workflow for pulling notes from a reMarkable tablet,
distilling them via Claude, and outputting clean Markdown files.

The heavy lifting (tablet communication, OCR) is handled by the `remarkable-mcp` submodule
in `vendor/remarkable-mcp`. This project adds the distillation layer on top.

## MCP Server

The remarkable-mcp server should be running in USB Web mode. Configuration is in
`.vscode/mcp.json`. The server connects to the tablet at `http://10.11.99.1` over USB.

OCR backend is set to `sampling` so Claude handles handwriting recognition directly
via the MCP sampling protocol — no external API keys needed.

## Distill Workflow

When the user asks to "process notes", "distill notes", or "sync from reMarkable":

1. **Fetch recent notes** — call `remarkable_recent` to list recently modified documents.
2. **Browse if needed** — call `remarkable_browse` to navigate folders or filter by tags.
3. **Read each note** — call `remarkable_read` on each document to extract text (OCR
   will trigger automatically for handwritten content via sampling).
4. **Distill** — restructure the extracted content into clean, well-organized Markdown:
   - Add a YAML frontmatter block: `title`, `date`, `source: reMarkable`, `tags`
   - Fix OCR artifacts (broken words, spurious characters)
   - Organize into logical sections with headers
   - Preserve the author's intent — don't add information that wasn't in the notes
   - Convert sketches/diagrams descriptions to text where possible
   - If the note is a list, keep it as a list; if prose, keep it as prose
5. **Write output** — save to `output/YYYY-MM-DD-<slug>.md` using the note title as slug.
6. **Report** — summarize what was processed and where files were written.

## Output Format

```markdown
---
title: "Note Title"
date: 2026-04-09
source: reMarkable
notebook: "/Folder/Notebook Name"
pages: [1, 2, 3]
tags: []
---

# Note Title

Distilled content here...
```

## Output Directory

- Default: `output/` in this repo
- If the user configures an Obsidian vault path, write there instead
- Track the configured output path in `.env` as `OUTPUT_DIR`

## Cross-Platform

This workflow runs on both macOS and Windows. When writing output paths:
- Use forward slashes in Markdown links and YAML frontmatter
- Respect the `OUTPUT_DIR` from `.env` — it may use Windows-style paths
- The MCP server (uvx) and Python stack work identically on both platforms

## Conventions

- Do not commit reMarkable auth tokens or credentials
- Do not commit raw OCR dumps — only distilled output
- Filenames use kebab-case: `2026-04-09-meeting-notes.md`
- One markdown file per reMarkable document (not per page)
