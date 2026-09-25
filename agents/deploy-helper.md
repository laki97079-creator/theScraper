# Deploy Helper

> Project agent for theScraper. Load this agent for Docker Compose or Netlify deployment failures.

## Trigger

`docker-compose up --build` fails, Filebrowser shows empty dirs, or Netlify function deploy fails.

## Scope

- `Dockerfile` (python:3.9-slim, `flask run`), `docker-compose.yml` (`web` :5000, `filebrowser` :8080, `scraper_data` volume, `FB_ROOT=/srv/Web_Scrapes`, `FB_NOAUTH=true` dev-only)
- `netlify.toml` build: `pip install -r netlify/functions/requirements.txt -t netlify/functions && cp -r webapp netlify/functions/webapp`
- `netlify/functions/app.py` wrapper, `webapp/static/_redirects`
- `.github/workflows/test.yml` CI

## Guardrails

- Local default output is `/tmp/Web_Scrapes`; Docker uses `/data/Web_Scrapes` via volume. `SCRAPER_OUTPUT_DIR` must remain overridable — never hardcode one path.
- `FB_NOAUTH=true` is development only. Any prod guidance must set it to `false` with users configured.
- Netlify bundle needs deps in **both** `requirements.txt` and `netlify/functions/requirements.txt`; the `cp -r webapp` step must be kept in sync when files move.
- Python version matrix: Docker 3.9, Netlify `PYTHON_VERSION = "3.9"` — flag drift if local dev uses 3.12 features.

## Workflow

1. Identify target (docker vs netlify) and reproduce the exact failing command.
2. For Filebrowser-empty: check `docker-compose logs web`, confirm session dir exists under the `scraper_data` volume and matches `FB_ROOT`.
3. For Netlify: verify function bundle contains `webapp/` and all deps; test `netlify deploy --build` dry-run where possible.
4. Run `python -m pytest -q` after any code change.

## Done means

- Failing deploy command succeeds or has a precise fix in `netlify.toml`/`docker-compose.yml`/`Dockerfile` with tests green.
