# ai-sandbox-ck

OctoMesh M0 walking-skeleton sandbox. Minimal CK-model project used by Claude
Code agents to validate end-to-end the vision in
[octo-ai-services/docs/concepts/vision.md](https://github.com/meshmakers/octo-ai-services/blob/main/docs/concepts/vision.md).

**Do not depend on this for production.** Schema may change; every PR may
add/remove/rename types.

## Build

```bash
dotnet build -c DebugL
```

## Preview (Mermaid class diagram)

```bash
./scripts/preview.sh
# Open preview/model.md in VS Code → click "Open Preview to the Side"
```

## What lives here

- `src/SandboxCkModel/` — CK-model project with baseline `Asset` type
- `cluster-config.yaml` — committed catalogue of MCP endpoints per cluster
- `scripts/` — convenience scripts (`preview.sh`, `init.sh`, `init.ps1`)
- `preview/` — `.gitignored`; per-session diagram output

## Used by

- M0 walking-skeleton (vision §7)
- M1 Pod-runtime validation (vision §8 M1)
- All later milestones for safe agent dry-runs

## Cluster targets

Listed in `cluster-config.yaml`. M0 primary target is **`local-dev`** —
OctoMesh services run native on your machine via the `Start-Octo` PowerShell
script in `octo-tools`. McpServices at `https://localhost:5017`,
IdentityServices at `https://localhost:5003`. A kind-on-Docker-Desktop cluster
runs in parallel just for backing services (MongoDB, CrateDB, RabbitMQ).

`staging-1` is set up in parallel for M1 (Pod-runtime needs a real K8s cluster).
`test-2` is optional. The `local-kind` slug is reserved for M1+ Helm-chart
tests against the AiWorker pod.

## Agent setup

See [setup.md](./setup.md) for the developer checklist (`init.sh`, OIDC, `gh` auth).
