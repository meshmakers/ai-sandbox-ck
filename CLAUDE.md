# CLAUDE.md — ai-sandbox-ck

Guidance for Claude Code working in this repo.

## What this repo is

A safe CK-model sandbox. Every change is a probe-PR — small, well-bounded,
disposable. **Never push to `main` directly.** Always open a PR for review.

## What this repo is NOT

- Not a production app
- Not a tenant-onboarding template
- Not a place to commit ephemeral files (preview/, dist/, etc. are `.gitignored`)

## Workflow

1. Read the current schema via the `ck-schema://ai-sandbox/domain` MCP Resource
   (automatically loaded at session start) before editing anything.
2. Edit YAML files under `src/SandboxCkModel/ConstructionKit/`. Follow the
   five gotchas in the `octo-ai-services` memory `ck-model-project-setup`:
   - Every type needs `derivedFromCkTypeId`
   - `ckModel.yaml` description is single-line
   - csproj references both `System.Bot` + `System.Communication`
   - `GlobalUsings.cs` includes the generated System namespace
   - `Directory.Build.props` `RestoreSources` order: local first for DebugL
3. Run `dotnet build -c DebugL` — must exit 0 with no warnings.
4. Run `./scripts/preview.sh` to regenerate the docs. Output lands in
   `preview/Sandbox/` as four Docusaurus-style markdown files:
   `index.md` (overview + Mermaid `classDiagram`), `Types.md`
   (per-type tables), `Attributes.md`, `VersionHistory.md`.
5. Open a PR via `gh pr create` with `--title` + `--body`. The `--body`
   MUST include the **Mermaid block extracted from `preview/Sandbox/index.md`**
   (the `\`\`\`mermaid` … `\`\`\`` fence) so the reviewer sees the diagram in
   the PR preview. Do NOT paste the whole file (cross-links resolve to
   `/Sandbox/Types#asset` which only works on a Docusaurus site, not in PR).

## YAML conventions in this repo

- Types: PascalCase filename, lowercase first letter of `typeId` segment
  (`asset.yaml` → `typeId: Asset` referenced as `${this}/Asset`)
- Enums: PascalCase
- Attributes: PascalCase, descriptive (no abbreviations)
- Associations: `<source>-<target>` filename, semantic role for the typeId
- Add one type per PR. Do not bundle.

## CK-model identifier

This repo's CK model is `Sandbox-1.0.0`. Do not bump the version unless making
breaking changes that need a migration. Within the sandbox we tolerate "messy"
schema evolution — minor additive PRs do not bump.

## Things to never do

- Do not write to runtime entities of any tenant (M0 reads schema only)
- Do not call `import_ck_model` or trigger any MCP background job
- Do not modify `Directory.Build.props` without verifying the build still works
- Do not commit anything under `preview/`, `bin/`, `obj/`
