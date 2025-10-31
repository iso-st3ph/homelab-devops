data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # ✅ Enforce IMDSv2, enable instance metadata tags
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # ✅ Explicit EBS optimization (T3 and most modern types support this)
  ebs_optimized = true

  # ✅ Secure, sensible root volume
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = merge(
    { Name = "homelab-ec2" },
    var.tags
  )
}
