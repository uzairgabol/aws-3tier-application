variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "name" {
  type = string
}

variable "internal" {
  type = bool
}

variable "port" {
  type = number
}

variable "health_check_path" {
  type = string
}