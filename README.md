## This repository is a Data Platform Landing Zone # Data Landing Zone Terraform Repo (Core + Add-ons)

This repo is intentionally **minimal**.

## What you deploy first
- `stacks/data-lz-core` — baseline landing zone for the **Data Platform subscription**:
  - VNet + subnets
  - Hub connectivity (VNet peering OR vWAN virtual hub connection)
  - Private DNS **VNet links** to hub-managed private DNS zones (scaffolding)
  - Optional Key Vault (baseline)

## Module layout
`modules/data-lz-core` is a single self-contained module (no nested component modules).

## Add-ons (optional)
Anything beyond the baseline belongs under:
- `modules/addons/*` and `stacks/addons/*`

Example included:
- `data-lz-qlik-ingestion` (optional) – shows how to add ingestion capabilities later without touching core.

## CI/CD
- Single pipeline: `azure-pipelines.yml`
  - Parameters: `action` (plan/apply/destroy) and `stackPath`

Backend: Azure Blob Storage (configured via pipeline variables).


## Hardening / robustness notes
- Hub VNet peering supports either `hub_vnet_id` **or** `hub_vnet_name + hub_resource_group_name` (module resolves id via data lookup).
- vWAN routing is optional; if you do not set `hub_virtual_hub_route_table_id` Azure defaults apply.
- Storage account security flags in the Qlik add-on use provider fields `allow_nested_items_to_be_public` and `shared_access_key_enabled`.
