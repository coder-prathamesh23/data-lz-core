# Stack: data-lz-core

This stack deploys the baseline Data Platform Landing Zone.

## What we deploy
- Landing zone resource group (protected by default)
- Spoke network
  - `network_mode=create`: we create the VNet, workload subnet, and private endpoints subnet
  - `network_mode=import`: we reference an existing VNet/subnets via data sources
- Optional baseline Key Vault
- Optional vWAN connectivity (vHub connection)
- Optional ADLS private endpoints (dfs + blob) and Private DNS zone attachment using centrally managed zones

## Notes
- We do not create Private DNS zones. We attach private endpoints to existing central zones using zone IDs provided by Cloud Services.
- Default route propagation across vWAN is controlled via `vhub_propagate_default_route`. We keep it false until Cloud Services confirms the expected setting.

## Safe destroy behavior
By default, the resource group is protected (`prevent_destroy`).
To allow destroy (for a sandbox), set:
`allow_resource_group_destroy = true`
