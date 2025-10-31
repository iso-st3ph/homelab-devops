# Pipelines

**Flow:** lint → plan → approve → apply → configure → smoke

- **Lint:** pre-commit (TFLint, Checkov, Ansible-lint, Hadolint)
- **Plan/Apply:** Terraform with remote backend (planned)
- **Configure:** Ansible targets AWS/Proxmox from TF outputs
- **Deploy:** Reverse proxy + sample app
- **Smoke:** curl healthchecks (non-200 fails the job)
