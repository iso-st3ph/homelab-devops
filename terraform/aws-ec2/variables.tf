variable "name" {
  type        = string
  default     = "homelab-ec2"
  description = "Name prefix for EC2 resources."
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy into."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type."
}

variable "enable_ssm_role" {
  type        = bool
  default     = true
  description = "Attach IAM role/profile for SSM Session Manager access. No SSH."
}

variable "key_name" {
  type        = string
  default     = null
  description = "SSH key pair name for EC2 instance access."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "VPC ID where instance will be deployed. If null, uses default VPC."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID where instance will run. If null, uses first subnet in default VPC."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to created resources."
}
