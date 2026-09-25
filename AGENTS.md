# AGENTS.md — theScraper

> Extracted and delivered with ultracode (ultravode) + project agents. See `docs/ULTRACODE_AND_AGENTS.md` for install and usage.

## Project snapshot

Flask web scraper UI (`webapp/`): discover internal links for base URLs, let the user select links, scrape text content into session folders.

- `webapp/app.py` — Flask routes: `/`, `/discover`, `/scrape_selected`, `/logs_stream`
- `webapp/scraper.py` — `start_link_discovery`, `discover_links_recursive` (max depth `MAX_DISCOVERY_DEPTH = 5`), `scrape_selected_pages`, `crawl_and_extract_single_page`
- `webapp/utils.py` — `logger`, `LogBufferHandler` (last 10 lines, streamed via SSE), `sanitize_filename`, `create_session_output_directory`, `ROOT_OUTPUT_DIR` (env `SCRAPER_OUTPUT_DIR`, default `/tmp/Web_Scrapes`)
- `webapp/templates/`, `webapp/static/` — Jinja templates + dark mode toggle + spinner/log view
- `tests/` — pytest suite using a local threaded HTTP server fixture (no external network)
- Deploy targets: Docker Compose (`web` + `filebrowser`), Netlify Functions (`netlify.toml`, `netlify/functions/app.py`)

## How to work in this repo

1. Python 3.9+ (CI uses 3.9; local dev verified on 3.12). Install: `pip install -r requirements.txt`
2. Run: `FLASK_APP=webapp/app.py flask run` → http://127.0.0.1:5000
3. Test: `python -m pytest -q` (11 tests, must stay green)
4. Scraper output: set `SCRAPER_OUTPUT_DIR` to a writable dir locally; Docker uses `/data/Web_Scrapes`
5. Keep footer attribution intact: `Developed as an open source resource by Daniel Gonzalez at ArtemisAI`
6. Do not enable Filebrowser auth bypass in production (`FB_NOAUTH=true` is dev-only)

## Agents in this repo (`agents/`)

| Agent | File | Use when |
|---|---|---|
| Scraper Maintainer | `agents/scraper-maintainer.md` | Changing routes, scraping logic, output dirs |
| Discovery Debugger | `agents/discovery-debugger.md` | Link discovery misses pages / loops / is slow |
| Deploy Helper | `agents/deploy-helper.md` | Docker or Netlify build/packaging failures |
| Test Guardian | `agents/test-guardian.md` | Adding features, keeping `pytest` green without network |

Each agent file states its trigger, scope, guardrails, and done criteria. Load only the agent you need.

## Ultracode (ultravode) code intelligence

Ultracode 5.15.0 is the codebase RAG / semantic-search MCP server for this repo. It requires **Bun + Node ≥ 24**.

- Install: `scripts/install-ultravode-agents.sh` (installs Bun, Node 24 via nvm if present, `bun i -g ultracode --trust`, Python deps)
- Run (must use Bun, not Node — the bundle imports `bun:` modules): `bun ~/.bun/install/global/node_modules/ultracode/dist/index.js /workspace`
- MCP config for Cursor: `.cursor/mcp.json` (server `ultracode`, command `bun`)
- Docs: `docs/ULTRACODE_AND_AGENTS.md`

## Guardrails for all agents and contributors

- `discovered_links_store` in `app.py` is a global in-memory dict — fine for single-user dev, must become per-session before multi-user prod.
- Respect politeness delays (`POLITENESS_DELAY = 0.5`) and request timeout (`REQUEST_TIMEOUT = 15`); do not remove them to "speed up" scraping.
- Sanitize every filename via `sanitize_filename`; never write outside the session output dir.
- Tests must not hit the public internet — extend the `local_site` fixture pattern in `tests/test_app.py`.
- Netlify functions bundle via `netlify.toml` build command — if you add a dependency, add it to both `requirements.txt` and `netlify/functions/requirements.txt` and verify the `cp -r webapp` packaging step still works.
