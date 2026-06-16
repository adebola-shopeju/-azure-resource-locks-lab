# Azure Resource Locks Lab

## Overview

This project documents a hands-on lab exploring **Azure Resource Locks** — a feature that protects cloud resources from accidental deletion or modification, regardless of the permissions (RBAC role) of the person attempting the action.

The lab covers how locks work, the three levels they can be applied at, how they interact with (and override) Role-Based Access Control, and how to manage them through both the Azure Portal and the Azure CLI.

## Environment Setup

| Resource | Type | Purpose |
|---|---|---|
| `RG-LockLab` | Resource Group | Container for all test resources |
| `storagelocklab` | Storage Account | Target for a `CanNotDelete` lock |
| `VM-LockLab` | Virtual Machine | Used to test lock inheritance |
| `NSG-LockLab` | Network Security Group | Target for a `ReadOnly` lock |

## Concepts Covered

| Topic | Summary |
|---|---|
| Cloud basics | The cloud is a rented office building; resources are the furniture inside it |
| Resource Locks | Like a padlock added to a specific door — independent of who holds a badge |
| Lock types | `CanNotDelete` = usable but not deletable; `ReadOnly` = view only, no changes |
| Lock levels | Can be applied at Subscription, Resource Group, or individual Resource level |
| Lock inheritance | A lock on a Resource Group automatically protects every resource inside it |
| Locks vs. RBAC | RBAC controls *who's allowed*; locks override that regardless of role — even a Subscription Owner can't bypass one |
| Management vs. Data Plane | Locks only affect the *control* layer (start/stop, delete, configure) — not the data flowing through a resource |

## Lab Tasks & Results

### Task 1 — Environment Setup
Created the resource group and three test resources (storage account, VM, NSG).
*Screenshots: `01-resource-group-created.png` → `04-nsg-created.png`*

### Task 2 — Applying Locks (Portal)
Applied a `CanNotDelete` lock to `storagelocklab` and a `ReadOnly` lock to `NSG-LockLab`.
*Screenshots: `05-cannotdelete-lock-applied.png`, `06-readonly-lock-applied.png`*

### Task 3 — Testing the Locks
Attempted to delete the storage account and modify the NSG; both actions were blocked with explicit lock-related error messages.
*Screenshots: `07-cannotdelete-error-message.png`, `08-readonly-error-message.png`*

### Task 4 — Resource Group-Level Lock & Inheritance
Applied a `CanNotDelete` lock (`Lock-RG-CanNotDelete`) directly to the resource group and confirmed that `VM-LockLab` automatically inherited it, with no extra configuration needed.
*Screenshots: `09-resource-group-locks-view.png` → `11-vm-inherited-lock.png`*

### Task 5 — Managing Locks via CLI
Used Azure Cloud Shell (Bash) to list, create, and remove locks:

```bash
# List all locks on a resource group
az lock list --resource-group RG-LockLab --output table

# Create a new lock via CLI
az lock create --name Lock-CLI-Test --resource-group RG-LockLab \
  --lock-type CanNotDelete --notes "Lock created via CLI for testing"

# Remove a lock via CLI
az lock delete --name Lock-CLI-Test --resource-group RG-LockLab
```

Confirmed that CLI-created locks appear identically to portal-created locks, and that deleting a lock via CLI produces no output on success — verified instead by re-running `az lock list`.
*Screenshots: `12-cli-list-locks.png`, `13-cli-create-lock.png`, `14-cli-remove-lock.png`*
*Full commands: see [`cli-commands.sh`](./cli-commands.sh)*

### Task 6 — Locks vs. RBAC
As the Subscription **Owner** (the highest RBAC role available), attempted to delete the locked storage account:

```bash
az storage account delete --name storagelocklab --resource-group RG-LockLab --yes
```

Result: blocked with a `ScopeLocked` error — critically, **not** a permissions error. This confirmed that locks operate independently of RBAC and override even the highest privilege level.
*Screenshot: `15-rbac-vs-lock-test.png`*

### Task 7 — Cascading Protection
Attempted to delete the entire resource group while it still contained locked resources:

```bash
az group delete --name RG-LockLab --yes
```

Result: blocked immediately with a `ScopeLocked` error at the resource group level — Azure refused the deletion of the whole group without needing to inspect resources inside it individually.
*Screenshot: `16-cascading-protection-test.png`*

## Key Takeaways

- Locks are **independent of identity** — they block an action for everyone, including Subscription Owners.
- Locks **inherit downward** automatically: Subscription → Resource Group → Resource.
- Locks only affect the **management plane** (configuration, deletion, start/stop) — not the **data plane** (actual data read/write inside a resource).
- The Azure CLI and Portal manage the exact same underlying lock objects — actions in one are immediately visible in the other.
- Error messages distinguish lock-based blocks (`ScopeLocked`) from RBAC-based blocks (`AuthorizationFailed`), which is a useful diagnostic signal in real-world troubleshooting.

## Repository Structure

```
azure-resource-locks-lab/
├── README.md
├── cli-commands.sh
└── screenshots/
    ├── 01-resource-group-created.png
    ├── 02-storage-account-created.png
    ├── 03-vm-created.png
    ├── 04-nsg-created.png
    ├── 05-cannotdelete-lock-applied.png
    ├── 06-readonly-lock-applied.png
    ├── 07-cannotdelete-error-message.png
    ├── 08-readonly-error-message.png
    ├── 09-resource-group-locks-view.png
    ├── 10-resource-group-lock-applied.png
    ├── 11-vm-inherited-lock.png
    ├── 12-cli-list-locks.png
    ├── 13-cli-create-lock.png
    ├── 14-cli-remove-lock.png
    ├── 15-rbac-vs-lock-test.png
    └── 16-cascading-protection-test.png
```
