# Projects

## 👇 Quick links
- **Terraform Module:** `terraform/modules/ec2_minimal/`
- **AWS Example:** `terraform/aws-ec2/`
- **Ansible Monitoring Role:** `ansible/roles/monitoring/`
- **Ansible Security Role:** `ansible/roles/secure/`
- **Monitoring Stack:** `docker/monitoring-stack/`
- **Reverse Proxy Demo:** `docker/reverse-proxy/`

---

## Monitoring Stack: Prometheus + Grafana

!!! abstract "What it does"
    - Full observability stack with Prometheus, Grafana, Node Exporter, and cAdvisor
    - Auto-provisioned Grafana datasources and dashboards
    - SELinux/Fedora compatible configurations
    - Makefile commands for easy management

**Try it**
```bash
make mon-up
# Access Grafana at http://localhost:3001
```

---

## Ansible: Monitoring Role

!!! abstract "What it does"
    - Deploys Prometheus Node Exporter to remote hosts
    - Installs as systemd service with security hardening
    - Auto-configures firewall (firewalld/ufw)
    - Idempotent deployment with version management

**Try it**
```bash
cd ansible
ansible-playbook playbooks/deploy-monitoring.yml
```

---

## Terraform: EC2 minimal

!!! abstract "What it does"
    - IMDSv2 required, EBS optimized, encrypted root volume  
    - Optional SSM instance profile (zero-SSH)  
    - Outputs public IP / instance ID

**Try it**
```bash
cd terraform/aws-ec2
terraform init -backend=false
terraform plan -var key_name=MY_KEY
```

