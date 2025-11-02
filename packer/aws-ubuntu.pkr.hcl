packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "homelab-ubuntu-22.04"
}

variable "ami_description" {
  type    = string
  default = "Ubuntu 22.04 LTS with security hardening and monitoring tools"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

# Source AMI filter for Ubuntu 22.04 LTS
source "amazon-ebs" "ubuntu" {
  ami_name        = "${var.ami_name}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  ami_description = var.ami_description
  instance_type   = var.instance_type
  region          = var.region
  vpc_id          = var.vpc_id
  subnet_id       = var.subnet_id

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ssh_username = var.ssh_username

  # Security hardening
  encrypt_boot = true
  kms_key_id   = ""

  # IMDSv2 enforcement
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Tags
  tags = {
    Name         = var.ami_name
    OS           = "Ubuntu"
    OSVersion    = "22.04"
    BuildDate    = formatdate("YYYY-MM-DD", timestamp())
    BuildTool    = "Packer"
    Environment  = "Production"
    ManagedBy    = "DevOps"
    Security     = "Hardened"
  }

  # Snapshot tags
  snapshot_tags = {
    Name      = "${var.ami_name}-snapshot"
    BuildDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Termination protection
  run_tags = {
    Name = "Packer Builder - ${var.ami_name}"
  }
}

build {
  name    = "ubuntu-hardened"
  sources = ["source.amazon-ebs.ubuntu"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "echo 'Cloud-init complete'"
    ]
  }

  # System updates
  provisioner "shell" {
    script = "scripts/01-system-update.sh"
  }

  # Install base packages
  provisioner "shell" {
    script = "scripts/02-install-packages.sh"
  }

  # Security hardening
  provisioner "shell" {
    script = "scripts/03-security-hardening.sh"
  }

  # Install monitoring tools
  provisioner "shell" {
    script = "scripts/04-install-monitoring.sh"
  }

  # Install Docker (optional)
  provisioner "shell" {
    script          = "scripts/05-install-docker.sh"
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  # Cleanup
  provisioner "shell" {
    script = "scripts/99-cleanup.sh"
  }

  # Validate image
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
