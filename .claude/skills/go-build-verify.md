When making any change to .go files in falah-os-workspace/, before staging or committing:

1. Run `go build ./...` in every module that was touched:
   - falah-os-workspace/CasaOS/
   - falah-os-workspace/CasaOS-AppManagement/
   - falah-os-workspace/CasaOS-Gateway/

2. All three must produce zero output (no errors). If any fails:
   - Read the full error
   - Identify ALL affected symbols in one pass (grep for the broken name across the whole module)
   - Fix every call site before committing — never fix one at a time and re-discover the rest

3. Only after `go build ./...` passes in all affected modules, stage and commit.

This prevents the "fix one broken identifier, find three more" loop that wastes tokens.
