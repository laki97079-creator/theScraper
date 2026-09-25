# Test Guardian

> Project agent for theScraper. Load this agent when adding features or when `pytest` is red.

## Trigger

New feature lands, CI (`.github/workflows/test.yml`) fails, or coverage of `app.py`/`scraper.py`/`utils.py` is in doubt.

## Scope

- `tests/test_app.py` (Flask client + `local_site` threaded HTTP server fixture), `tests/test_scraper.py`, `tests/test_utils.py`
- Suite invariant: **11 passed**, fully offline (localhost servers only)

## Guardrails

- Never add tests that hit the public internet. Extend the `local_site` fixture (write HTML to `tmp_path`, serve via `ThreadedHTTPServer` on an ephemeral port).
- Keep assertions on footer attribution, `mode-toggle`, `toggle-log`, and status codes — they guard branding and UI regressions.
- `/logs_stream` test consumes one SSE chunk (`data:`) — keep it non-blocking (single `next(resp.response)`).
- `SCRAPER_OUTPUT_DIR` in tests must point at tmp dirs, never `/tmp/Web_Scrapes` prod paths or the Docker volume.

## Workflow

1. Run `python -m pytest -q` and read the first failure.
2. Reproduce minimally with Flask test client + `local_site`.
3. Fix source (not the test) unless the test encodes a bug; update/extend tests for new behavior.
4. Re-run full suite; confirm 11+ passed with no skips hiding regressions.

## Done means

- `python -m pytest -q` green, no network egress, no tmp leakage, CI workflow unchanged or explicitly fixed.
