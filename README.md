# dsh-lite-agent

A **minimal, low-noise agent preset and companion profile** for [DeepSeek Harness][dsh]/DSH — built for small tasks and minimal code changes where you don't want the full coding-agent machinery.

It is a trimmed-down clone of the shipped `standard` preset:

- **No subagent tools** — no `subagent`, `subagent_fork`, `list_agents`, `workflow`, `ralph`, goal, plan-mode, or web search tools.
- **Project-only skills** — the skills catalog is restricted to the current project's own skill directories (`.dsh/skills`, `.agents/skills`, `.claude/skills`). Global *-cli skills, superpowers p[...]
- **A bare system prompt** — the persona is the *entire* system prompt (`complete: true`, `includeRuntimeContext: false`). No auto-appended identity/web/tool guidance.

## What you get

| Concern | `standard` | `lite` |
| --- | --- | --- |
| Shell | `bash` / `pwsh` | `bash` / `pwsh` |
| Filesystem | `fs`, `fs-search` | `fs`, `fs-search` |
| Background jobs | `jobs` | `jobs` |
| Skills | global + project | **project only** |
| Subagents / workflows / ralph | yes | **no** |
| Goals / plan-mode / web search | yes | **no** |
| System prompt | rich, assembled | **bare self-contained** |

Tool rows after boot: `bash`, `pwsh`, `jobs`, `fs`, `fs-search`, `skill`, `ask-user`, `todo` — plus whatever your project's AGENTS.md instructions need.

## Repository layout

```
dsh-lite-agent/
├── agent-presets/
│   └── lite/                      # the agent preset
│       ├── preset.yml             # name + description (picker metadata)
│       └── agent.cordis.yml       # the Cordis composition (the preset itself)
└── profiles/
    └── lite/                      # the companion DSH profile
        ├── package.json           # bundle list (dsh-base + dsh-web-app, NO superpowers)
        ├── cordis.yml             # empty profile root (do not edit)
        ├── cordis.patch.yml       # hides global skills + defaults to `lite`
        └── pnpm-workspace.yaml    # pnpm workspace config for the profile
```

## Install (two parts)

Quick one-liner installer (copy-paste on the command line)

```bash
# Install preset only:
curl -fsSL https://github.com/ynsr/dsh-lite-agent/install.sh | bash

# Install preset + companion profile (opt-in):
curl -fsSL https://github.com/ynsr/dsh-lite-agent/install.sh | bash -s -- --profile
```

### 1. Install the agent preset

Copy the `agent-presets/lite/` directory into your DSH home so the preset roster picks it up:

```bash
mkdir -p "$HOME/.dsh/.agent-presets"
cp -r agent-presets/lite "$HOME/.dsh/.agent-presets/lite"
```

It appears in the preset picker as **Lite Agent**. End a session and start a new one on it — the preset decides tool schemas and prompt sections, so only a fresh session shows what this preset p[...]

### 2. (Optional) Install the companion lite profile

The profile drops the `superpowers-dsh` bundle and hides global skill roots **deployment-wide**, so you do not have to touch your default `web` profile. Install it under `$DSH_HOME/profiles` and b[...]

```bash
cp -r profiles/lite "$HOME/.dsh/profiles/lite"
dsh --profile lite      # or: dsh lite
```

Inside that profile, the default agent preset is already `lite`.

> **Installing dependencies:** the profile's `package.json` references the standard DSH bundles (`@deepseek-ai/dsh-base`, `@deepseek-ai/dsh-web-app`). If they are not already installed for your DS[...]

## How it works

- **Agent preset (`agent.cordis.yml`)** — an AGENT-PLANE composition. It registers only tool/skill/prompt sections and publishes no service, so it needs no `isolate` realm. Its `skill-filesystem[...]
- **Profile (`profiles/lite`)** — the bundle list simply omits the `superpowers-dsh` bundle (the source of the superpowers skills), and `cordis.patch.yml` points the host `skill-filesystem` at p[...]

## Notes & limitations

- A single preset cannot *remove* skills that the deployment registers at the **host layer** (e.g. if your `web` profile bundles `superpowers-dsh`). The project-only filtering works on the preset'[...]
- Global user skills (`~/.dsh/skills/*`, e.g. *-cli) are excluded because the lite preset's `skill-filesystem` does not scan user roots.
- This is an AGENT-PLANE artifact. The registries themselves (tools, skills, sandbox, approval, persistence, model route) stay on the host plane — nothing here moves them.

## License

MIT.

[dsh]: https://github.com/deepseek-ai
