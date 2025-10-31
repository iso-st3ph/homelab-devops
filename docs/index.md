# Homelab DevOps Overview

[![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker)](https://www.docker.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)](https://www.jenkins.io/)
[![MkDocs](https://img.shields.io/badge/MkDocs-Docs-000000?logo=markdown)](https://www.mkdocs.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](../LICENSE)

> :rocket: **Goal:** Demonstrate a production-style DevOps pipeline: _lint → plan → approve → apply → configure → smoke test_ across cloud and homelab targets.

## Pipeline at a glance

```mermaid
flowchart TD
  A[Developer Laptop] -->|Git Push| B[GitHub Actions / Jenkins]
  B -->|Static Checks| C[Pre-commit · TFLint · Checkov · Ansible-lint · Hadolint]
  B -->|Plan| D[Terraform Plan]
  D -->|Manual Gate| E[Approve]
  E -->|Apply| F[Terraform Apply]
  F -->|Configure| G[Ansible Playbooks]
  G -->|Deploy/Proxy| H[Docker Reverse Proxy]
  F -->|Alt Target| I[Proxmox VM + NFS]
  G -->|Smoke Tests| J[Health Checks]
```
