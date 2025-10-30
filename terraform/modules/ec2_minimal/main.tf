provider "aws" {
  region = var.region
}

# Safe-by-default: resources commented until you're ready to deploy.
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
#   }
# }

# resource "aws_instance" "this" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.instance_type
#   key_name      = var.key_name
#   tags          = merge({ Name = "homelab-ec2" }, var.tags)
# }
