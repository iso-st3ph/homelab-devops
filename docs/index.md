# Homelab DevOps Overview

```mermaid
flowchart TD
  A[Developer Laptop] -->|Git Push| B[GitHub Actions]
  B -->|Run Ansible Checks| C[Ansible Playbooks]
  B -->|Validate IaC| D[Terraform AWS EC2]
  A -->|SSH / API| E[Proxmox Cluster]
  E --> F[NFS Storage (45Drives)]
  E --> G[Proxmox Backup Server]
```
