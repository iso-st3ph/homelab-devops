variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "enable_ssm_role" {
  description = "Attach an instance profile with AmazonSSMManagedInstanceCore so the instance can be managed without SSH."
  type        = bool
  default     = true
}
