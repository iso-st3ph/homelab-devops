# Architecture

```mermaid
flowchart LR
  Dev[Dev Laptop] -->|git push| CI[CI (GitHub Actions/Jenkins)]
  CI --> Lint[Static checks\npre-commit · TFLint · Checkov · Ansible-lint · Hadolint]
  CI --> Plan[Terraform Plan]
  Plan -->|manual gate| Approve[Approve]
  Approve --> Apply[Terraform Apply]
  Apply --> AWS[AWS: EC2/SG/VPC]
  Apply --> Proxmox[Proxmox VM]
  Proxmox --> NFS[NFS (45Drives)]
  Apply --> DNS[DNS/Records]
  AWS --> Ansible[Ansible Config]
  Proxmox --> Ansible
  Ansible --> App[Reverse Proxy + App (Docker)]
  App --> Smoke[Smoke tests/health checks]
```
