# homelab-devops
_A practical DevOps portfolio built from a real homelab environment._

![CI](https://github.com/iso-st3ph/homelab-devops/actions/workflows/ci.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-validated-blueviolet?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-tested-darkred?logo=ansible)
![Docker](https://img.shields.io/badge/Docker-ready-blue?logo=docker)

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
