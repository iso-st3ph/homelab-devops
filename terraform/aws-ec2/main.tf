terraform {
  # Local state by default (safe in repo); S3 backend example commented.
  # backend "s3" {
  #   bucket  = "YOUR-BUCKET"
  #   key     = "tfstate/homelab-devops/aws-ec2.tfstate"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}

module "ec2_minimal" {
  source        = "../modules/ec2_minimal"
  region        = var.region
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.tags
}
