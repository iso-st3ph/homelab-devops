# Getting Started with IsoVault

## Requirements

## PBS Token Creation
1. Log in to PBS.
2. Create a new API token with restricted scope for your backup namespace.
3. Note the token ID and secret.

## Client Install Options
### Linux (Debian/Ubuntu)
```sh
sudo apt update
sudo apt install proxmox-backup-client
```

### Docker
```sh
docker run --rm -it \
  -e PBS_REPOSITORY="your-pbs-server:8007:namespace" \
  -e PBS_USERNAME="your-token-id" \
  -e PBS_PASSWORD="your-token-secret" \
  proxmox/backup-client:latest
```

## Example Backup Command
```sh
proxmox-backup-client backup docs.pxar=./myfolder
```

## Restore & Verify
```sh
proxmox-backup-client restore docs.pxar /restore/path
proxmox-backup-client list
```

For more details, see [Security](../security.md).
