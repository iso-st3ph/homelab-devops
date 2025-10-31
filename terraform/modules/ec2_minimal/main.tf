data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

# Optional IAM role/profile so the instance can be managed via SSM (no SSH)
resource "aws_iam_role" "ssm" {
  count = var.enable_ssm_role ? 1 : 0

  name_prefix = "homelab-ec2-ssm-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.enable_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count       = var.enable_ssm_role ? 1 : 0
  name_prefix = "homelab-ec2-profile-"
  role        = aws_iam_role.ssm[0].name
  tags        = var.tags
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  monitoring    = true

  # Enforce IMDSv2 + tag access
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  ebs_optimized = true

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  # Attach profile when enabled (null when disabled)
  iam_instance_profile = try(aws_iam_instance_profile.ssm[0].name, null)

  tags = merge(
    { Name = "homelab-ec2" },
    var.tags
  )
}