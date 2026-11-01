#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install selected Agent Toolkit MCP servers in Claude Code, Codex, or both.

Usage:
  bash scripts/install-mcps.sh

The installer is interactive. It writes user-level MCP configuration.
For MySQL, export MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, and MYSQL_DATABASE
before running this script. MYSQL_PORT is optional and defaults to 3306.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
fi

choose_clients() {
  local answer
  printf 'Install for: [1] Claude Code  [2] Codex  [3] Both\n'
  read -r -p 'Choose 1, 2, or 3: ' answer
  case "$answer" in
    1) clients=(claude) ;;
    2) clients=(codex) ;;
    3) clients=(claude codex) ;;
    *) printf 'Invalid client selection.\n' >&2; exit 2 ;;
  esac
}

choose_servers() {
  local answer item
  printf '\nAvailable servers:\n'
  printf '  1) GitHub    2) Linear    3) MySQL    4) Playwright\n'
  read -r -p 'Enter one or more numbers separated by commas (for example 1,2,4): ' answer
  IFS=',' read -r -a selected_numbers <<< "$answer"
  for item in "${selected_numbers[@]}"; do
    item="${item//[[:space:]]/}"
    case "$item" in
      1) servers+=(github) ;;
      2) servers+=(linear) ;;
      3) servers+=(mysql) ;;
      4) servers+=(playwright) ;;
      *) printf 'Invalid server selection: %s\n' "$item" >&2; exit 2 ;;
    esac
  done
  if [[ ${#servers[@]} -eq 0 ]]; then
    printf 'Select at least one MCP server.\n' >&2
    exit 2
  fi
}

has_server() {
  local client="$1" name="$2"
  if [[ "$client" == claude ]]; then
    claude mcp get "$name" >/dev/null 2>&1
  else
    codex mcp get "$name" >/dev/null 2>&1
  fi
}

require_mysql_environment() {
  local name
  for name in MYSQL_HOST MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE; do
    if [[ ! -v "$name" ]]; then
      printf 'MySQL was selected, but %s is not set. Export the required MYSQL_* variables and rerun the installer.\n' "$name" >&2
      exit 2
    fi
    if [[ -z "${!name}" ]]; then
      printf 'MySQL was selected, but %s is empty. Set it and rerun the installer.\n' "$name" >&2
      exit 2
    fi
  done
  MYSQL_PORT="${MYSQL_PORT:-3306}"
}

install_claude() {
  local name="$1"
  case "$name" in
    github)
      claude mcp add --transport http --scope user github https://api.githubcopilot.com/mcp/
      ;;
    linear)
      claude mcp add --transport http --scope user linear https://mcp.linear.app/mcp
      ;;
    playwright)
      claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest --headless
      ;;
    mysql)
      claude mcp add --scope user \
        --env "MYSQL_HOST=$MYSQL_HOST" \
        --env "MYSQL_PORT=$MYSQL_PORT" \
        --env "MYSQL_USER=$MYSQL_USER" \
        --env "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
        --env "MYSQL_DATABASE=$MYSQL_DATABASE" \
        mysql -- uvx mysql_mcp_server
      ;;
  esac
}

install_codex() {
  local name="$1"
  case "$name" in
    github)
      codex mcp add github --url https://api.githubcopilot.com/mcp/
      ;;
    linear)
      codex mcp add linear --url https://mcp.linear.app/mcp
      ;;
    playwright)
      codex mcp add playwright -- npx -y @playwright/mcp@latest --headless
      ;;
    mysql)
      codex mcp add \
        --env "MYSQL_HOST=$MYSQL_HOST" \
        --env "MYSQL_PORT=$MYSQL_PORT" \
        --env "MYSQL_USER=$MYSQL_USER" \
        --env "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
        --env "MYSQL_DATABASE=$MYSQL_DATABASE" \
        mysql -- uvx mysql_mcp_server
      ;;
  esac
}

declare -a clients=()
declare -a servers=()
choose_clients
choose_servers

for client in "${clients[@]}"; do
  if ! command -v "$client" >/dev/null 2>&1; then
    printf '%s CLI is not installed or is not on PATH.\n' "$client" >&2
    exit 127
  fi
done

for server in "${servers[@]}"; do
  case "$server" in
    mysql)
      command -v uvx >/dev/null 2>&1 || { printf 'uvx is required for MySQL. Install uv first.\n' >&2; exit 127; }
      require_mysql_environment
      ;;
    playwright)
      command -v npx >/dev/null 2>&1 || { printf 'npx is required for Playwright. Install Node.js first.\n' >&2; exit 127; }
      ;;
  esac
done

for server in "${servers[@]}"; do
  if [[ "$server" == mysql ]]; then
    printf '\nMySQL credentials will be written to the selected client user configuration.\n'
    read -r -p 'Continue? [y/N] ' confirmation
    case "$confirmation" in
      y|Y|yes|YES) ;;
      *) printf 'Cancelled before making changes.\n'; exit 0 ;;
    esac
    break
  fi
done

for client in "${clients[@]}"; do
  for server in "${servers[@]}"; do
    if has_server "$client" "$server"; then
      printf '%s is already configured in %s; skipping it. Remove it first if you want to replace its configuration.\n' "$server" "$client"
      continue
    fi
    printf '\nInstalling %s for %s...\n' "$server" "$client"
    if [[ "$client" == claude ]]; then
      install_claude "$server"
    else
      install_codex "$server"
    fi
  done
done

cat <<'EOF'

Installation commands completed.
- Claude Code: run /mcp in a session to authenticate remote servers and inspect status.
- Codex: run codex mcp login github and/or codex mcp login linear when OAuth is required, then codex mcp list.
- MySQL credentials are stored in the client user's local MCP configuration. Keep those files private.
EOF
