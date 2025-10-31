# Projects

## Terraform: EC2 Minimal Module
- Opinionated tags, keypair, security group.
- Outputs feed Ansible inventory.
- **Code:** `terraform/modules/ec2_minimal/`
- **Try it:** `terraform/examples/ec2_minimal/`

## Ansible: Nginx/Hardening role
- Idempotent tasks, handler notifications, Molecule-ready layout.
- **Playbook:** `ansible/site.yml`
- **Role:** `ansible/roles/secure/`

## Docker: Reverse Proxy Demo
- `docker-compose.yml` with a `whoami` app behind the proxy.
- Healthchecks + simple smoke script.
- **Folder:** `docker/reverse-proxy/`

## CI/CD
- Pre-commit: fmt/validate + yamllint.
- (Optional) GitHub Actions `docs.yml` to auto-publish MkDocs.
- Jenkinsfile mirrors IaC workflow with a manual gate.
