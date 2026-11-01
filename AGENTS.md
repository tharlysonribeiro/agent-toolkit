# Agent Instructions

## Repository purpose

This repository provides reusable skills, plugins, hooks, and MCP configurations for Claude Code and Codex.

## Working guidelines

- Keep shared agent instructions in this file and keep `CLAUDE.md` focused on Claude Code-specific behavior.
- Keep the toolkit plugin components at the repository root, alongside the Claude Code and Codex manifests.
- Keep client-specific MCP examples in `mcp/` when their configuration formats differ.
- Never commit credentials, access tokens, private database details, or machine-specific paths.
- Prefer official or clearly maintained MCP server implementations and link to their source.
- Keep installation instructions concise and state runtime and authentication requirements.
