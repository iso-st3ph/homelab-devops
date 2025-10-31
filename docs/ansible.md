# Ansible Automation

My homelab uses Ansible to automatically configure and deploy workloads across:

- 🏠 **Proxmox VMs** (Docker nodes, NGINX proxy, Wazuh, PBS)
- ☁️ **AWS EC2 instances** (created via Terraform)
- 🗃️ **45Drives NFS storage**
- 🔐 **Security services** (hardening, users, SSH, fail2ban)
- 📦 **Application stack** (Docker containers, monitoring, reverse proxy)

This ensures consistent, repeatable infrastructure both at home and in the cloud.

---

## 🚀 End-to-End Automation Flow

```mermaid
flowchart LR
  Git[Developer Commit] --> CI[CI Pipeline: lint/validate/test]
  CI --> Terraform[Terraform Apply]
  Terraform --> Inventory[Generate Dynamic Inventory]
  Inventory --> Ansible[Run Ansible Playbooks]
  Ansible --> Deploy[Deploy Apps & Config]
  Deploy --> Health[Smoke Tests / Health Checks]

[proxmox]
dockenode1 ansible_host=192.168.1.201
dockenode2 ansible_host=192.168.1.202
wazuh ansible_host=192.168.1.203
proxy ansible_host=192.168.1.204
pbs ansible_host=192.168.1.205

[aws]
aws-prod ansible_host=54.123.45.67

- name: Base configuration
  hosts: all
  become: yes

  roles:
    - common      # users, system settings
    - security    # firewall, fail2ban, ssh hardening
    - docker      # docker + compose install
```

## ✅ Ansible Execution Screenshot

Below is a real run of my Ansible playbook against my homelab VMs:

![Ansible Run](assets/ansible-run.png)

## 🔧 Ansible Workflow Diagram

```mermaid
flowchart LR
  GH[Git Push to GitHub] --> CI[CI Pipeline]
  CI --> Lint[Lint + Security Scan]
  CI --> Deploy[Run Ansible Playbook]
  Deploy --> Proxmox[Configure Proxmox VMs]
  Deploy --> AWS[Configure AWS EC2 Instance]
  Proxmox --> Services[Deploy Homelab Services]
  AWS --> Services
  Services --> Smoke[Smoke Tests / Health Checks]

  [proxmox]
192.xxx.x.xxx
192.xxx.x.xxx

[aws]
3.89.xx.xx

- name: Homelab Automation Demo
  hosts: all
  become: true

  tasks:
    - name: Ping test
      ping:

    - name: Ensure NGINX installed (example)
      apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"
```
