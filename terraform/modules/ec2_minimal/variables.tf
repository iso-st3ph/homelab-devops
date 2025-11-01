variable "name" {
  type    = string
  default = "homelab-ec2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "enable_ssm_role" {
  type    = bool
  default = true
}

variable "key_name" {
  type    = string
  default = null # null => no SSH key injected (SSM only)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
