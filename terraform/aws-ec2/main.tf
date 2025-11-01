provider "aws" {
  region = var.aws_region
}

# Discover default VPC/subnet only if not provided
data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "in_vpc" {
  count = var.vpc_id == null && var.subnet_id == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [one(data.aws_vpc.default[*].id)]
  }
}

data "aws_subnet" "chosen" {
  count = var.vpc_id == null && var.subnet_id == null ? 1 : 0
  id    = data.aws_subnets.in_vpc[0].ids[0]
}

locals {
  effective_vpc_id    = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.default[*].id)
  effective_subnet_id = var.subnet_id != null ? var.subnet_id : one(data.aws_subnet.chosen[*].id)
}

module "ec2_minimal" {
  source    = "../modules/ec2_minimal"
  vpc_id    = local.effective_vpc_id
  subnet_id = local.effective_subnet_id

  name            = var.name
  instance_type   = var.instance_type
  key_name        = var.key_name
  enable_ssm_role = var.enable_ssm_role
  tags            = var.tags
}
