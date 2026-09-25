# Ultravode (Ultracode) + Agents — extraction & install report

> Request was `Extract and deliver ultravode and agents. Install`. There is no `ultravode` package or in-repo agent system, so this interprets `ultravode` as **ultracode** (the codebase RAG / MCP server, npm `ultracode` 5.15.0) and delivers project agents extracted from this repo's actual architecture.

## What was extracted

From `webapp/app.py`, `webapp/scraper.py`, `webapp/utils.py`, `tests/`, `Dockerfile`, `docker-compose.yml`, `netlify.toml`:

| Delivered | Path | Purpose |
|---|---|---|
| Agent index + contributor rules | `AGENTS.md` | Snapshot, how-to-run, guardrails |
| Scraper Maintainer agent | `agents/scraper-maintainer.md` | Routes / scraping / output changes |
| Discovery Debugger agent | `agents/discovery-debugger.md` | Link-discovery misses, loops, slowness |
| Deploy Helper agent | `agents/deploy-helper.md` | Docker + Netlify failures |
| Test Guardian agent | `agents/test-guardian.md` | Keep `pytest` green, offline |
| One-shot installer | `scripts/install-ultravode-agents.sh` | Python deps + Bun + Node 24 + ultracode |
| Cursor MCP wiring | `.cursor/mcp.json` | `ultracode` server via `bun` |
| Node pin | `.nvmrc` | `24` (ultracode requires Node ≥ 24) |

## Install (verified 2026-09-25 on this VM; update-checked 2026-09-25 — latest remains 5.15.0)

Project deps + tests:

```bash
pip install -r requirements.txt
python -m pytest -q   # 11 passed
```

Full stack (does everything above plus ultracode):

```bash
bash scripts/install-ultravode-agents.sh
```

What the script does:

1. `pip install -r requirements.txt` (+ Netlify function reqs)
2. Installs Bun if missing (`curl -fsSL https://bun.sh/install | bash`)
3. Ensures Node ≥ 24 via nvm (`nvm install 24`) when nvm is present
4. `bun i -g ultracode --trust` (npm path is **not** usable — the bundle imports `bun:` modules and crashes under Node with `ERR_UNSUPPORTED_ESM_URL_SCHEME`)
5. Verifies with `bun <global ultracode>/dist/index.js --version` (expect `ultracode 5.15.0`)

Manual equivalent:

```bash
export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$PATH"
bun i -g ultracode --trust
bun ~/.bun/install/global/node_modules/ultracode/dist/index.js --version
```

## Run ultracode on this repo

Must run under **Bun**, not Node:

```bash
bun ~/.bun/install/global/node_modules/ultracode/dist/index.js /workspace
# optional: --no-auto-index, --config <path>, --pipe for multi-client
```

Interactive provider setup (embeddings):

```bash
bun ~/.bun/install/global/node_modules/ultracode/dist/index.js setup
# or: ultracode-setup (resolves the same setup-command.js)
```

## Cursor MCP config

`.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "ultracode": {
      "command": "bun",
      "args": ["~/.bun/install/global/node_modules/ultracode/dist/index.js", "/workspace"]
    }
  }
}
```

Use `~` expansion or the absolute home path if your client does not expand it. Restart Cursor after editing.

## Environment notes / caveats

- `ultracode` shim symlinks (`~/.bun/bin/ultracode`) carry a `#!/usr/bin/env node` shebang and **fail** under Node (`bun:` protocol unsupported). Always invoke via `bun <path>`.
- npm `install -g ultracode` succeeds but the result is unrunnable without Bun; the installer script therefore prefers the Bun path.
- `EBADENGINE` warning under Node 22 is expected — switch to Node 24 (`nvm use 24`) or just use Bun.
- No secrets are required for local indexing; embedding-provider setup (`ultracode setup`) may ask for provider keys depending on your choice.
