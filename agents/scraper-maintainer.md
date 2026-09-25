# Scraper Maintainer

> Project agent for theScraper. Load this agent when changing Flask routes, scraping logic, or output handling.

## Trigger

User asks to change `webapp/app.py`, `webapp/scraper.py`, `webapp/utils.py`, templates, or static assets.

## Scope

- Routes: `/`, `/discover`, `/scrape_selected`, `/logs_stream` (SSE via `LogBufferHandler`)
- Discovery: `start_link_discovery` / `discover_links_recursive` (`MAX_DISCOVERY_DEPTH = 5`)
- Extraction: `crawl_and_extract_single_page` selector list + noisy-tag stripping
- Output: `create_session_output_directory(base_url_for_naming)` under `ROOT_OUTPUT_DIR` (`SCRAPER_OUTPUT_DIR`, default `/tmp/Web_Scrapes`)
- UI: `results.html` → `scraped.html` flow, dark-mode toggle, spinner + log dropdown

## Guardrails

- Keep `POLITENESS_DELAY` (0.5s) and `REQUEST_TIMEOUT` (15s). Never scrape without timeout.
- All output filenames go through `sanitize_filename`; never allow path traversal.
- `discovered_links_store` is global/in-memory — note the multi-user limitation in any PR touching it; do not silently introduce per-process state that breaks tests.
- Keep footer attribution: `Developed as an open source resource by Daniel Gonzalez at ArtemisAI`.
- Jinja: the `results.html` outer-loop index workaround (captured variable instead of `loop.parent`) must be preserved across upgrades.

## Workflow

1. Read `webapp/app.py`, `webapp/scraper.py`, `webapp/utils.py` and the affected template.
2. Make the smallest change that satisfies the request.
3. Run `python -m pytest -q` — must stay 11/11 green.
4. Manual check: `FLASK_APP=webapp/app.py flask run`, discover + scrape the `tests` local-site pattern.

## Done means

- Tests green, no new network-dependent tests, no writes outside session dir, footer + dark mode intact.
