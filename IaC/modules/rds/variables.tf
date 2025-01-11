variable "vpc_id" {
  type = string
}

variable "private_subnet_db" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}