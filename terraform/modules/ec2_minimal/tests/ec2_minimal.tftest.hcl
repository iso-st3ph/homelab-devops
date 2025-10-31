# Use a mocked AWS provider so no network/creds are required
mock_provider "aws" {
  mock_data "aws_ami" {
    # attributes returned to the module's data.aws_ami.ubuntu
    defaults = {
      id = "ami-12345678"
    }
  }
}

# Inputs to the module
variables {
  instance_type   = "t3.micro"
  key_name        = "dummy"
  tags            = {}
  enable_ssm_role = true
}

# Validate the module plans successfully with mocks
run "plan_module" {
  command = plan
  module {
    source = "../"
  }
}
