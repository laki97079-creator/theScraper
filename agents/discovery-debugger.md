# Discovery Debugger

> Project agent for theScraper. Load this agent when link discovery misses pages, loops, is slow, or errors.

## Trigger

Discovery returns too few/too many links, hangs, recurses too deep, or logs request failures.

## Scope

- `discover_links_recursive` in `webapp/scraper.py`: `visited_discovery_urls`, `discovered_links_set`, `discovery_stats`, fragment stripping, `base_url_to_match` prefix check
- Constants: `MAX_DISCOVERY_DEPTH = 5`, `POLITENESS_DELAY / 2` between recursive calls, `REQUEST_TIMEOUT = 15`

## Guardrails

- Stay same-origin via the `startswith(base_url_to_match)` check; do not broaden scope to external domains without explicit user approval.
- Do not raise `MAX_DISCOVERY_DEPTH` without measuring blowup — discovery is depth-first recursive and can explode on large sites.
- Keep `allow_redirects=True` behavior and request-exception handling (warn, don't crash discovery).
- Log with `logger.info/debug/warning` so the SSE log stream (`/logs_stream`) stays informative.

## Workflow

1. Reproduce with the `local_site` fixture pattern (`tests/test_app.py`) — two-page local HTTP server, never the public internet.
2. Check: base URL normalization, fragment removal, visited-set updates, depth cutoff logging.
3. Fix, then verify counts: `checked` vs `found` in `discovery_stats`.
4. Run `python -m pytest -q`.

## Done means

- Local reproduction passes, no infinite recursion, stats log correctly, tests green.
