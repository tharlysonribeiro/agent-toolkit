# Agent Toolkit

A personal plugin for Claude Code and Codex, with reusable skills, hooks, and MCP setup examples.

The Karpathy Guidelines and Coding Principles skills are available to both clients. A single `SessionStart` hook adds both guideline texts to each new session. The hook requires Python 3.

## Install the plugin

### Claude Code

```text
/plugin marketplace add tharlysonribeiro/agent-toolkit
/plugin install agent-toolkit@agent-toolkit
```

### Codex

```bash
codex plugin marketplace add tharlysonribeiro/agent-toolkit
codex plugin add agent-toolkit@agent-toolkit
```

Alternatively, install **Agent Toolkit** from Codex's Plugins directory after adding the marketplace. Review and trust the `SessionStart` hook when prompted.

For local development, use the repository path instead of `tharlysonribeiro/agent-toolkit`.

## Install skills with APM

The APM package includes the local `karpathy-guidelines` skill.

```bash
apm install tharlysonribeiro/agent-toolkit#master --target agent-skills
```

This installs the latest version from the `master` branch.

## MCP servers

Choose and install GitHub, Linear, MySQL, and Playwright with the interactive installer:

```bash
bash scripts/install-mcps.sh
```

It configures only the clients and servers you select. See [MCP.md](MCP.md) for prerequisites, project-level setup, authentication, and manual configuration examples in [`mcp/`](mcp/).

[CodeGraph](https://github.com/colbymchenry/codegraph) is a separate local code-navigation MCP server; install it using its upstream instructions.

## Project instructions

`AGENTS.md` contains shared guidance for work inside this repository. `CLAUDE.md` imports it for Claude Code. Installing the plugin does not copy either file into consuming projects.

## Karpathy Guidelines source

The bundled Karpathy Guidelines use [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) as a reference. The source link and license declaration are retained in the skill metadata.
