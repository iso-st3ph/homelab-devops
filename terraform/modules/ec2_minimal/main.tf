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
  count       = var.enable_ssm_role ? 1 : 0
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

# Egress-only SG (no SSH ingress)
resource "aws_security_group" "egress_only" {
  name        = "${var.name}-egress-only-sg"
  description = "No inbound rules; allow all egress"
  vpc_id      = var.vpc_id

  #checkov:skip=CKV_AWS_382:Egress to 0.0.0.0/0 is intentional - allows instance to download updates and access AWS services
  egress {
    description = "Allow all outbound traffic for system updates and AWS service access"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.name}-egress-only-sg" }, var.tags)
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  monitoring    = true

  # set var.key_name = null to avoid SSH key injection (SSM only)
  key_name = var.key_name

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.egress_only.id]

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

  iam_instance_profile = try(aws_iam_instance_profile.ssm[0].name, null)

  tags = merge({ Name = var.name }, var.tags)
}
