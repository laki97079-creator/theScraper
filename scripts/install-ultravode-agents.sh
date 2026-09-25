#!/usr/bin/env bash
# Install ultravode (ultracode) + project agents for theScraper.
# - Python deps + pytest check
# - Bun runtime (required: ultracode bundle imports `bun:` modules)
# - Node >= 24 via nvm when available (ultracode EBADENGINE under Node 22)
# - ultracode 5.15.0 via `bun i -g ultracode --trust`
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> 1/4 Python dependencies"
pip install -r requirements.txt
if [ -f netlify/functions/requirements.txt ]; then
  pip install -r netlify/functions/requirements.txt || true
fi

echo "==> 2/4 Bun runtime"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PATH="$BUN_INSTALL/bin:$PATH"
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
bun --version

echo "==> 3/4 Node >= 24 (via nvm if present)"
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.nvm/nvm.sh"
  nvm install 24 || true
  nvm use 24 || true
fi
node --version || true

echo "==> 4/4 ultracode (ultravode)"
bun i -g ultracode --trust
ULTRA_ENTRY="$HOME/.bun/install/global/node_modules/ultracode/dist/index.js"
bun "$ULTRA_ENTRY" --version

echo ""
echo "==> Verify project tests"
python3 -m pytest -q

echo ""
echo "Done. Run ultracode with:"
echo "  bun $ULTRA_ENTRY $ROOT"
echo "Cursor MCP config: .cursor/mcp.json (server 'ultracode', command 'bun')"
echo "Agents: AGENTS.md + agents/*.md — full report: docs/ULTRACODE_AND_AGENTS.md"
