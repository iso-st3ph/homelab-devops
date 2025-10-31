provider "aws" {
  region = var.region
}

module "ec2_minimal" {
  source        = "../modules/ec2_minimal" # adjust if your path differs
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.tags
}