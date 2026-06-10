# Developer setup — ai-sandbox-ck

One-time per developer. Estimated time: ~1 hour.

## Prerequisites

- macOS / Linux / WSL2 — the scripts/ use bash
- .NET SDK 10.0.x installed (`dotnet --version` ≥ `10.0.0`)
- `gh` CLI installed and authenticated against `meshmakers/` org
- `yq` installed (`brew install yq` on macOS, `apt install yq` on Debian/Ubuntu) for `init.sh`
- `claude` CLI installed; logged in with a Max/Team/Enterprise subscription
- SSH agent set up per the `octo-ai-services` memory `ssh-git-push` (Keeper socket on macOS):
  ```bash
  export SSH_AUTH_SOCK='/var/folders/.../keeper-ssh-agent.sock'
  ```
- For `local-dev` target (M0 primary): the OctoMesh services must be running locally. Start them via `Start-Octo` from `octo-tools` (PowerShell). This starts IdentityServices (`:5002`/`:5003`), McpServices (`:5016`/`:5017`), AssetRepositoryServices, BotServices, CommunicationControllerServices and friends as native processes; backing services (MongoDB, CrateDB, RabbitMQ) come from a kind-on-Docker-Desktop cluster running in parallel.

## Steps

1. Clone this repo
   ```bash
   git clone git@github.com:meshmakers/ai-sandbox-ck.git
   cd ai-sandbox-ck
   ```

2. Verify build
   ```bash
   dotnet build -c DebugL    # must exit 0
   ```

3. (For `local-dev` target only) Start the Octo services locally
   ```powershell
   # In a PowerShell session:
   cd /Users/gerald/RiderProjects/meshmakers/octo-tools
   ./Start-Octo.ps1
   ```
   Leave that terminal open; the services run there. McpServices at `https://localhost:5017`, IdentityServices at `https://localhost:5003`.

4. Generate `.mcp.json` for your target
   ```bash
   # Default (local-dev):
   ./scripts/init.sh

   # Or pick a remote cluster:
   ./scripts/init.sh -c staging-1
   # or:
   ./scripts/init.sh -c test-2
   ```

   Windows-native developers run `./scripts/init.ps1` instead (needs `Install-Module powershell-yaml -Scope CurrentUser`).

5. Authenticate against MCP
   ```bash
   claude
   # Inside the session, type:
   > authenticate
   # Follow the device-flow URL, log in with your account
   # Verify:
   > get_available_types
   # Should return at least the Sandbox/Asset type
   ```

6. First test run
   ```bash
   claude
   > List all CK types and attributes in the sandbox.
   # Agent should respond with the contents of Sandbox-1.0.0
   ```

If step 6 returns the schema, you are ready for the M0 walking-skeleton run.
