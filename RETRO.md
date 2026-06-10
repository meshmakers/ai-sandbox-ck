# M0 Walking-Skeleton — Retro (2026-06-10)

## TL;DR

M0 walking-skeleton **passed on first attempt**: a single English-language
goal ("Add a `MaintenanceTicket` CK type with Title, Severity and an
Asset association") produced a convention-correct 5-file diff, a valid
Mermaid class diagram in the PR body, and a clean local build — all
landed in [PR #1](https://github.com/meshmakers/ai-sandbox-ck/pull/1)
(merged as `277ae1c`).

The notable friction was **not** the agent; it was the dev-environment
plumbing around it. Three sharp edges to fix before we move the same
flow into a Pod for M2.

---

## What worked

- **First-try success on CK conventions.** No re-prompts needed. The
  agent got `${this}/…` scoping, numeric enum keys, asymmetric `One`/`N`
  multiplicities, the `associationRoles` file layout, and `$schema`
  annotations right on the first edit. This is the strongest possible
  signal that the sandbox + embedded `CLAUDE.md` template carry enough
  context for a one-line goal to land conventionally.
- **Minimal, focused diff.** 5 new files, +44/-0 lines, zero edits to
  `asset.yaml`. The agent correctly recognised that the inverse
  `MaintenanceTickets` role is defined on the association file, not by
  modifying the target type — a non-obvious idiom of the CK model.
- **Mermaid in the PR body rendered cleanly on GitHub.** Both the
  inheritance edge (`MaintenanceTicket --|> Entity`) and the labelled
  cardinality edge (`MaintenanceTicket "1" --> "n" Asset :
  Sandbox/AffectsAsset`) survived round-trip through `octo-ckc
  generateDocs` + GitHub's Mermaid renderer. This pins the "PR-quality
  artefact, not just code" intent from `vision.md`.

## What hurt

- **`mcp-bridge.js` was stateless — and we discovered this the hard
  way.** The `Mcp-Session-Id` header that McpServices returns on
  `initialize` was being thrown away, so every later request came back
  HTTP 400 with `JsonRpcError`. About 30 minutes of debugging before the
  smoking gun (`curl -D -` showed the header that the bridge dropped).
  Fixed in
  [octo-mcp-service `73956c1`](https://github.com/meshmakers/octo-mcp-service/commit/73956c1).
- **`OCTO_TENANT` hardcoded to `sbeg` in the bridge** worked here only
  because that's the sandbox tenant slug today. A future tenant with a
  different slug would have inherited a confusing 400-loop with no
  signposting. Should be config-driven (or auto-resolved from CWD).
- **NuGet cache drift between repos.** After the
  `Sdk.Common.Encryption` extraction in `octo-sdk` (commit `70abff9`),
  the local `octo-ai-services` could not compile its integration tests
  against the stale `Meshmakers.Octo.Sdk.Common` package in `../nuget/`.
  Needed `invoke-buildall -branch main -configuration DebugL
  -excludeFrontend -excludeAdditional` to repopulate. CI was green the
  whole time because it builds from scratch, which masked the local
  drift. Worth a note in the M0 setup guide.
- **MCP server is not registered out-of-the-box.** First run gave
  "no MCP servers" until we registered `octo-mesh` at user-scope via
  `claude mcp add -s user octo-mesh node …/mcp-bridge.js`. The setup
  doc should call this out as the first step after `Start-Octo`, not
  leave the user to discover it.

## Surprises (smaller, worth recording)

- The agent ran `dotnet build -c DebugL` *and* `./scripts/preview.sh`
  before opening the PR — both showed up as checked rows on the test
  plan. We did not prompt for this; the embedded `CLAUDE.md` had
  enough hint to do it. Keep that.
- The agent picked the branch name `add-maintenance-ticket` from the
  goal verbatim. Acceptable; we'd reach for slugifying the original
  type id once we have a convention.
- The PR body footer carried the `🤖 Generated with Claude Code`
  attribution automatically. Fine for the sandbox; we'll likely want
  to suppress that on real tenant repos.

## Carry-overs into M2 prep (Pod runtime, test-2 dry-run)

These are the items the retro turns into work:

1. **#29 — direct-HTTP MCP transport.** Retires the bridge entirely.
   Today blocked by the .NET dev cert not being trusted by claude
   code's HTTP client (rustls vs macOS keychain). Solve before M2 so
   the Pod runtime never inherits a custom bridge step.
2. **Setup-doc gap.** Add a "register `octo-mesh` MCP server" step
   plus a "run `invoke-buildall` first if you touched shared
   libraries" step to the M0 setup section. Both bit us today.
3. **Tenant slug resolution.** The bridge (or its replacement) must
   not hardcode a tenant slug. Either env var, project-config, or
   auto-discover from `Start-Octo`'s registered tenants.

## M2 go / no-go

**Go.** All ten §3 code-side gates (encryption round-trip, approval
demotion contract, JobKind seam, Helm chart 0.5.0, CI green at HEAD)
are evidence-backed, and M0 just demonstrated the same Goal → PR flow
the Pod will run. The three carry-overs above are M2-prep work, not
M2-blocker work — the Pod can come up on test-2 with the bridge still
in place, and we replace it before any flow that demands the HTTP
transport.

See [`octo-ai-services/docs/concepts/m0-m1-validation.md`](https://github.com/meshmakers/octo-ai-services/blob/main/docs/concepts/m0-m1-validation.md)
for the full validation table.
