# MCP server setup

This repository provides four MCP integrations: GitHub, Linear, MySQL, and Playwright. Install each server separately from the Agent Toolkit plugin so every machine can choose its own services and credentials.

## Interactive installer

The installer asks which client to configure and which servers to install. It writes user-level configuration, so the selected MCPs are available in all projects for that client.

```bash
bash scripts/install-mcps.sh
```

The script requires Bash and the selected client CLI (`claude`, `codex`, or both). It skips servers that already exist; remove a server first if you want to replace its settings.

| Server | Additional requirement | What happens |
| --- | --- | --- |
| GitHub | GitHub account | Adds GitHub's hosted server. Complete OAuth in Claude Code or run `codex mcp login github`. |
| Linear | Linear account | Adds Linear's hosted server. Complete OAuth in Claude Code or run `codex mcp login linear`. |
| MySQL | `uv` and a MySQL database | Starts the local `mysql_mcp_server` package and uses the `MYSQL_*` environment variables below. |
| Playwright | Node.js and `npx` | Starts Microsoft's Playwright MCP server in headless mode. `npx` downloads it at first launch. |

### MySQL environment

Set the host, user, database, and password in the same terminal before running the installer. The port is optional and defaults to `3306`.

```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=agent_toolkit
export MYSQL_DATABASE=your_database
read -rsp 'MySQL password: ' MYSQL_PASSWORD
printf '\n'
export MYSQL_PASSWORD
bash scripts/install-mcps.sh
```

When prompted, select MySQL and the client or clients to configure. The installer passes these values to the client CLI, which stores them in that client's user-level MCP settings. Keep those settings private. Use a dedicated MySQL account with only the permissions your workflows need; the server can execute SQL.

## Verify and authenticate

Claude Code:

```bash
claude mcp list
```

Start Claude Code and run `/mcp` to complete remote OAuth and inspect live connection status.

Codex:

```bash
codex mcp list
codex mcp login github
codex mcp login linear
```

Run the login commands for the remote servers you installed. If the Codex version reports that the remote MCP client is disabled, add this to `~/.codex/config.toml` and restart Codex:

```toml
[features]
experimental_use_rmcp_client = true
```

## Install manually

The MCP configuration examples are in `mcp/claude-code/` and `mcp/codex/`. Use these if you prefer not to run the installer or want project-level configuration.

### Claude Code

For user-level configuration, which applies across projects:

```bash
claude mcp add --transport http --scope user github https://api.githubcopilot.com/mcp/
claude mcp add --transport http --scope user linear https://mcp.linear.app/mcp
claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest --headless
```

For MySQL, use the installer for user-level setup. For project-level setup, add the `mcpServers.mysql` entry from `mcp/claude-code/mysql.json` to the project's `.mcp.json`. Set the `MYSQL_*` environment variables before starting Claude Code; the JSON entry expands them at runtime.

Use `--scope project` instead of `--scope user` to store a server in the current project's `.mcp.json`. Review that file before committing it. Do not put literal passwords or tokens in a shared project file.

### Codex

These commands add remote servers to your user configuration:

```bash
codex mcp add github --url https://api.githubcopilot.com/mcp/
codex mcp add linear --url https://mcp.linear.app/mcp
codex mcp add playwright -- npx -y @playwright/mcp@latest --headless
```

For MySQL, the installer passes the environment values to `codex mcp add`. To keep credentials out of Codex configuration, use the `env_vars` example in `mcp/codex/mysql.toml` instead and provide those variables in the environment where Codex starts.

For project-level Codex configuration, create `.codex/config.toml` in the project and copy only the server tables you need from `mcp/codex/*.toml`. Codex loads project configuration only for trusted projects. The examples use `env_vars` for MySQL so the password does not need to be written into that file.

## Troubleshooting

- **The server is missing:** run `claude mcp list` or `codex mcp list`. Restart the client after changing configuration.
- **GitHub or Linear shows as disconnected:** start a Claude Code session and run `/mcp`, or run `codex mcp login github` / `codex mcp login linear` for the server you installed.
- **MySQL fails to start:** confirm `uvx` is on `PATH`, all four required `MYSQL_*` variables are set, and `MYSQL_DATABASE` names an accessible database. The installer only reads the variables from the shell in which it runs.
- **Playwright fails to start:** confirm `node` and `npx` are on `PATH`, then retry after `npx` has downloaded `@playwright/mcp`.
- **A server has the wrong settings:** remove it with the command below, then rerun the installer. The installer leaves existing configurations unchanged.

## Remove an MCP server

```bash
claude mcp remove SERVER_NAME
codex mcp remove SERVER_NAME
```

Replace `SERVER_NAME` with `github`, `linear`, `mysql`, or `playwright`. Removing a server disconnects it from that client; it does not uninstall system runtimes such as Node.js or `uv`.

## Upstream server documentation

- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Linear MCP](https://linear.app/docs/mcp)
- [MySQL MCP Server](https://github.com/designcomputer/mysql_mcp_server)
- [Playwright MCP](https://github.com/microsoft/playwright/tree/main/packages/mcp)

For client configuration details, see the [Claude Code MCP guide](https://code.claude.com/docs/en/mcp) and the [Codex MCP guide](https://developers.openai.com/learn/docs-mcp).
