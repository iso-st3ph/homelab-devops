# Projects

## 👇 Quick links
- **Terraform Module:** `terraform/modules/ec2_minimal/`
- **AWS Example:** `terraform/aws-ec2/`
- **Ansible Role:** `ansible/roles/secure/`
- **Reverse Proxy Demo:** `docker/reverse-proxy/`

---

## Terraform: EC2 minimal
!!! abstract "What it does"
    - IMDSv2 required, EBS optimized, encrypted root volume  
    - Optional SSM instance profile (zero-SSH)  
    - Outputs public IP / instance ID

**Try it**

cd terraform/aws-ec2
terraform init -backend=false
terraform plan -var key_name=MY_KEY

