# homelab-devops

_A practical DevOps portfolio_: Ansible automation, Terraform on AWS, and containerized services.  
**Tech:** Linux, Ansible, Terraform, Docker, GitHub Actions, AWS.

## Structure

## Quickstart
- `ansible/playbooks/patch.yml` — safely patch Linux hosts (simulate with `--check`)
- `terraform/aws-ec2` — `terraform init && terraform validate`
- `docker/reverse-proxy` — `docker compose up -d` (local)

> No secrets are committed. Use environment variables or local files ignored by git.

## Roadmap
- [ ] Add Jenkinsfile for CI/CD
- [ ] Add Packer for AMI builds
- [ ] Add Prometheus/Grafana docker stack
- [ ] Add Proxmox API Terraform examples
