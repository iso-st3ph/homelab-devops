# Terraform Infrastructure

This repo provisions compute both in **AWS** and **Proxmox**.

## ✅ Components Managed

| Platform | Resources | Notes |
|---------|----------|------|
| AWS     | EC2 Instance, networking | Terraform Cloud-Init + Ansible bootstrap |
| Proxmox | VMs provisioned via Terraform provider | Integrates with local homelab |

---

## 🗂️ Folder Structure

```bash
terraform/
├─ aws-ec2/
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  └─ tests/
└─ modules/
   └─ ec2_minimal/
      ├─ main.tf
      ├─ variables.tf
      ├─ outputs.tf
      └─ tests/

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
public_ip = "X.X.X.X"
instance_id = "i-abc123"

| Feature               | Status |
| --------------------- | ------ |
| IMDSv2 enforced       | ✅      |
| EBS encrypted         | ✅      |
| Checkov clean         | ✅      |
| No hard-coded creds   | ✅      |
| SSM IAM role optional | ✅      |

```mermaid
flowchart LR
Dev --> GitHub
GitHub --> CI[Terraform CI Checks]
CI --> Plan[terraform plan]
Plan --> Gate[Manual Approval]
Gate --> Apply[terraform apply]
Apply --> AWS[(AWS EC2)]
Apply --> Proxmox[(Proxmox VM)]
```mermaid
