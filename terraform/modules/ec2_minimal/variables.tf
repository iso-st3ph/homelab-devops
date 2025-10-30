variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
