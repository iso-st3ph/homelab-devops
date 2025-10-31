[![Deploy Docs](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml)

# Homelab DevOps Portfolio

Live site: https://iso-st3ph.github.io/homelab-devops/


[![Infra Lint](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml) [![Docs](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml/badge.svg)](https://iso-st3ph.github.io/homelab-devops/)

<!-- # homelab-devops
_A practical DevOps portfolio built from a real homelab environment._ -->

![CI](https://github.com/iso-st3ph/homelab-devops/actions/workflows/ci.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-validated-blueviolet?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-tested-darkred?logo=ansible)
![Docker](https://img.shields.io/badge/Docker-ready-blue?logo=docker)
[![Infra Lint](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/infra-ci.yml)
[![Docs](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml/badge.svg)](https://github.com/iso-st3ph/homelab-devops/actions/workflows/docs.yml)


This repository showcases **automation and infrastructure management** for my personal homelab.  
It demonstrates real-world experience using **Ansible, Terraform, Docker, and GitHub Actions** — the same tools used in modern DevOps environments.

---

## 📚 Table of Contents
- [🧠 Tech Stack](#-tech-stack)
- [📁 Repository Structure](#-repository-structure)
- [🚀 Quickstart](#-quickstart)
- [🛠️ Roadmap](#️-roadmap)
- [👨‍💻 Author](#-author)

---

## 🧠 Tech Stack
- **Linux / Fedora / Ubuntu**
- **Ansible** – system automation and patch management  
- **Terraform** – infrastructure as code (AWS + Proxmox examples)  
- **Docker Compose** – lightweight service orchestration  
- **GitHub Actions** – CI/CD automation and syntax validation  
- **AWS** – cloud infrastructure provisioning  

---

## 📁 Repository Structure

---

## 🚀 Quickstart

### Ansible
```bash
cd ansible
ansible-playbook playbooks/patch.yml --check --diff -K

---

## 🤝 Contributing / Contact
Questions or ideas? Open an Issue or reach out:

- **LinkedIn:** https://www.linkedin.com/in/stephon-skipper/
- **Site:** https://ayoskip.info

If this repo helped you, ⭐ it and follow along as I add Jenkins, Packer, Grafana/Prometheus, and Proxmox automation.

### CI/CD
- **GitHub Actions**: default CI (syntax/validate)
- **Jenkins**: `Jenkinsfile` mirrors the same checks for enterprise environments

## What’s inside
- **IaC:** Terraform (EC2 module with IMDSv2, SSM, encrypted volumes)
- **Config:** Ansible baseline role
- **Containers:** Reverse proxy demo
- **CI:** pre-commit, TFLint, Checkov, Hadolint, Ansible-lint, Terraform tests
- **Docs:** MkDocs Material → https://iso-st3ph.github.io/homelab-devops/
