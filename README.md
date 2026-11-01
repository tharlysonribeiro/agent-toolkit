# Agent Toolkit

A personal plugin for Claude Code and Codex, with reusable skills, hooks, and MCP setup examples.

The Karpathy Guidelines skill is available to both clients. A `SessionStart` hook also adds the full guideline text to each new session. The hook requires Python 3.

## Install the plugin

### Claude Code

```text
/plugin marketplace add tharlysonribeiro/agent-toolkit
/plugin install agent-toolkit@agent-toolkit
```

### Codex

```bash
codex plugin marketplace add tharlysonribeiro/agent-toolkit
```

Then install **Agent Toolkit** from Codex's Plugins directory. Review and trust the `SessionStart` hook when prompted.

For local development, use the repository path instead of `tharlysonribeiro/agent-toolkit`.

## Install skills with APM

The APM package includes the local `karpathy-guidelines` skill and Matt Pocock's [`grill-me`](https://github.com/mattpocock/skills) skill with its `grilling` dependency, pinned to `v1.3.2`.

```bash
apm install tharlysonribeiro/agent-toolkit#v0.1.0
```

The upstream skills are pinned to Matt Pocock's `v1.3.2` release in this repository's `apm.yml`. APM records the resolved revision and content hashes in `apm.lock.yaml`. Publish the matching `v0.1.0` tag before using this command.

## Recommended skills

- [Ponytail](https://github.com/DietrichGebert/ponytail) — install its official plugin.
- [Orca](https://github.com/stablyai/orca) — agent skill for building with Orca.
- [Diagram Design](https://github.com/cathrynlavery/diagram-design) — skill for clear technical diagrams.

## MCP servers

Choose and install GitHub, Linear, MySQL, and Playwright with the interactive installer:

```bash
bash scripts/install-mcps.sh
```

It configures only the clients and servers you select. See [MCP.md](MCP.md) for prerequisites, project-level setup, authentication, and manual configuration examples in [`mcp/`](mcp/).

## Project instructions

`AGENTS.md` contains shared guidance for work inside this repository. `CLAUDE.md` imports it for Claude Code. Installing the plugin does not copy either file into consuming projects.

## Karpathy Guidelines source

The bundled Karpathy Guidelines use [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) as a reference. The source link and license declaration are retained in the skill metadata.
