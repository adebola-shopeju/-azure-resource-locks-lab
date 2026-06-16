#!/bin/bash
# Azure Resource Locks Lab — CLI Commands
# Run these in Azure Cloud Shell (Bash) after Tasks 1–4 are complete
# (resource group, storage account, VM, NSG, and portal-applied locks already exist)

# ---------------------------------------------------------
# TASK 5: List, create, and remove locks via CLI
# ---------------------------------------------------------

# List all locks currently applied to the resource group
az lock list --resource-group RG-LockLab --output table

# Create a new test lock via CLI
az lock create \
  --name Lock-CLI-Test \
  --resource-group RG-LockLab \
  --lock-type CanNotDelete \
  --notes "Lock created via CLI for testing"

# Confirm the new lock appears in the list
az lock list --resource-group RG-LockLab --output table

# Remove the test lock via CLI (no output on success)
az lock delete --name Lock-CLI-Test --resource-group RG-LockLab

# Confirm the lock is gone
az lock list --resource-group RG-LockLab --output table


# ---------------------------------------------------------
# TASK 6: Test locks vs. RBAC
# As Subscription Owner, attempt to delete a locked resource.
# Expected result: blocked with a ScopeLocked error, NOT a
# permissions/authorization error — proving locks override RBAC.
# ---------------------------------------------------------

az storage account delete \
  --name storagelocklab \
  --resource-group RG-LockLab \
  --yes


# ---------------------------------------------------------
# TASK 7: Test cascading protection
# Attempt to delete the entire resource group while it still
# contains locked resources (and has its own direct lock).
# Expected result: blocked immediately at the resource group
# level with a ScopeLocked error.
# ---------------------------------------------------------

az group delete \
  --name RG-LockLab \
  --yes
