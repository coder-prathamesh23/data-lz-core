# Data Platform Landing Zone (Terraform)

This repo is intentionally minimal and structured for a core landing zone with optional add-ons.

## What we deploy first
`stacks/data-lz-core` deploys the baseline landing zone for the Data Platform subscription:
- Landing zone resource group (protected by default)
- Spoke network
  - create a new VNet + subnets, or import an existing one
- Optional baseline Key Vault
- Optional vWAN connectivity (vHub connection)
- Optional ADLS private endpoints (dfs + blob) attached to centrally managed Private DNS zones

## Key design points
- Cloud Services owns hub/shared connectivity and central DNS. We reference central DNS zone IDs and do not create DNS zones.
- We keep network creation controlled via `network_mode` so we can switch between a single-run deployment (create) and a split foundation model (import).

## Layout
- `modules/data-lz-core` — core landing zone resources
- `stacks/data-lz-core` — orchestration + environment-specific inputs

## CI/CD
- `azure-pipelines.yml` runs fmt/validate, plan, and an approval-gated apply.
- Backend: Azure Blob Storage (configured via pipeline variable group).
