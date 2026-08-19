# Figma REST API Sync

This integration retrieves the source node used by the five landing-page templates and stores a JSON snapshot in `figma/snapshots/`. It can also export the node as a PNG presentation mockup.

## One-time setup

1. Copy `.env.example` to `.env`.
2. Replace its value with the Figma personal access token you generated.
3. Keep `.env` private; it is ignored by Git.

## Sync

```powershell
./scripts/Sync-Figma.ps1 -LoadEnv
```

Use `-SkipExport` to save only the JSON node data.

```powershell
./scripts/Sync-Figma.ps1 -LoadEnv -SkipExport
```

Add additional file/node pairs to `sources.json` as the library grows. The script only needs Figma's `file_content:read` scope for these read operations. Figma exports are regenerated locally and are ignored by Git.

## Available sources

```powershell
# Landing-page designs 51–55
./scripts/Sync-Figma.ps1 -LoadEnv -Source landing-pages-51-55

# Free Mockups — Community library
./scripts/Sync-Figma.ps1 -LoadEnv -Source free-mockups-library

# Individual mockup from the Community library
./scripts/Sync-Figma.ps1 -LoadEnv -Source free-mockup-5-6051
```

The configured mockup-library node is a Figma `CANVAS` (a container), so it saves a JSON reference only. To export a specific mockup image, copy that mockup frame's Figma link, add it as a new source with its `nodeId`, and omit `"export": false`.
