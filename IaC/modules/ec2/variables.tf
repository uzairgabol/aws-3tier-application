variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "user_data_script" {
  type = string
}

variable "enable_public_ip" {
  type    = bool
  default = false
}

variable "depends_on_resource" {
  type    = any
  default = []
}