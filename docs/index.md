# Homelab DevOps Overview

> :rocket: **Golden Path** — _lint → plan → approve → apply → configure → smoke_ across AWS & homelab (Proxmox/NFS).  
> Built with **Terraform · Ansible · Docker · GitHub Actions · Jenkins · MkDocs**.

[![Infra Lint](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml)
[![Docs](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml)

## Pipeline at a glance

```mermaid
flowchart TD
  A[Developer Laptop] -->|Git Push| B[GitHub Actions / Jenkins]
  B -->|Static Checks| C[pre-commit · TFLint · Checkov · Ansible-lint · Hadolint]
  B -->|Plan| D[Terraform Plan]
  D -->|Manual Gate| E[Approve]
  E -->|Apply| F[Terraform Apply]
  F -->|Configure| G[Ansible Playbooks]
  G -->|Deploy/Proxy| H[Docker Reverse Proxy]
  F -->|Alt Target| I[Proxmox VM + NFS]
  G -->|Smoke Tests| J[Health Checks]

## 📁 Projects

- 🏗️ [Terraform Infrastructure](terraform.md)
- 🤖 [Ansible Automation](ansible.md)
- 🐳 [Docker Reverse Proxy](docker.md)
- 🛰️ End-to-end DevOps CI/CD Lab

---

## 🎯 About This Lab

This homelab is built to simulate real-world DevOps:

✅ Git-based workflows  
✅ CI pipelines & automated linting  
✅ Terraform infrastructure provisioning  
✅ Ansible configuration management  
✅ Docker applications behind a reverse proxy  

> Goal: Operate like a production infrastructure in a home lab environment.
