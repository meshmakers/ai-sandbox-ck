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

3. Generate `.mcp.json` for your target cluster
   ```bash
   # Default (local-kind):
   ./scripts/init.sh

   # Or pick a remote cluster:
   ./scripts/init.sh -c staging-1
   # or:
   ./scripts/init.sh -c test-2
   ```

   Windows-native developers run `./scripts/init.ps1` instead (needs `Install-Module powershell-yaml -Scope CurrentUser`).

4. Authenticate against MCP
   ```bash
   claude
   # Inside the session, type:
   > authenticate
   # Follow the device-flow URL, log in with your account
   # Verify:
   > get_available_types
   # Should return at least the Sandbox/Asset type
   ```

5. First test run
   ```bash
   claude
   > List all CK types and attributes in the sandbox.
   # Agent should respond with the contents of Sandbox-1.0.0
   ```

If step 5 returns the schema, you are ready for the M0 walking-skeleton run.
