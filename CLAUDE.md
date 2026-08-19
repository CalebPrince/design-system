# figma-design-library — instructions for Claude

This repo is the design source of truth for this user's UI work. When generating or
editing any frontend UI — in this repo or elsewhere, if the user points you here —
prefer what's documented here over generic/default styling choices.

## Order of precedence when building UI

1. **Live Figma data** (when a Figma link is given or more detail is needed) — use the
   `figma` MCP server (`plugin:figma:figma`, backed by `https://mcp.figma.com/mcp`) to
   pull the actual frame/component/variables instead of guessing from a snapshot.
2. **Design tokens** — `design-systems/foundations/*/tokens.json` (colors, typography,
   spacing, grids, elevation). Use these values verbatim; don't invent new hex codes,
   spacing units, or type scales when a token already covers the case.
3. **Component specs** — `design-systems/components/*/README.md` for variant and
   behavior contracts (buttons, inputs, cards, navigation, modals, tables, forms).
4. **Templates** — `templates/<category>/*/README.md` (+ `tokens.json` per template)
   for full-page composition patterns already adapted from Figma sources. Check for a
   matching template before composing a page from scratch.
5. **Local Figma snapshots** — `figma/snapshots/*.json` and exported PNGs in
   `mockups/presentation/` when MCP access isn't available or a static reference is
   enough. See `figma/sources.json` for what's tracked and `figma/README.md` for how
   to refresh a snapshot via `scripts/Sync-Figma.ps1`.

## Conventions

- Naming: `docs/naming-conventions.md`.
- Contribution flow: `docs/contributing.md`.
- Figma provenance/licensing notes for adapted templates: `docs/figma-source.md`.

## Adding new Figma sources

To track a new Figma file/frame as a static snapshot: add an entry to
`figma/sources.json` (`fileKey`, `nodeId` from the Figma URL, `snapshotPath`,
`exportPath`), then run `./scripts/Sync-Figma.ps1 -LoadEnv -Source <name>`. Requires
`FIGMA_ACCESS_TOKEN` in a local `.env` (see `.env.example`) — never commit it.
