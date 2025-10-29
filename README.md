# homelab-devops
_A practical DevOps portfolio built from a real homelab environment._

![CI](https://github.com/iso-st3ph/homelab-devops/actions/workflows/ci.yml/badge.svg)

This repository showcases **automation and infrastructure management** for my personal homelab.  
It demonstrates real-world experience using **Ansible, Terraform, Docker, and GitHub Actions** — the same tools used in modern DevOps environments.

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
