terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# NOTE: This resource is commented so 'validate' passes without creating anything.
# Uncomment when you're ready to 'apply' in a real account with proper credentials.
# resource "aws_instance" "example" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   tags = { Name = "homelab-devops-example" }
# }

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type    = string
  default = "ami-0c101f26f147fa7fd" # Example: Ubuntu 22.04 in us-east-1 (update as needed)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

output "plan_ready" {
  value = "Terraform validated. Uncomment resources to provision."
}
