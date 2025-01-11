terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# IAM Module
module "iam" {
  source = "./modules/iam"
}

# RDS Module
module "rds" {
  source            = "./modules/rds"
  vpc_id            = module.vpc.vpc_id
  private_subnet_db = module.vpc.private_subnet_db
  rds_sg_id         = module.security_groups.rds_sg_id
}

# Backend EC2 Module
module "backend_ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnet_app[0]
  sg_id             = module.security_groups.app_sg_id
  iam_role_name     = module.iam.instance_profile_name
  instance_name     = "AppTierInstance"
  user_data_script  = "launch_app-tier.sh"
  enable_public_ip  = false
  depends_on_resource = [module.rds]
}

# Internal ALB Module
module "internal_alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnet_app
  sg_id             = module.security_groups.internal_alb_sg_id
  instance_id       = module.backend_ec2.instance_id
  name              = "App-Internal-ALB"
  internal          = true
  port              = 4000
  health_check_path = "/health"
}

# Frontend EC2 Module
module "frontend_ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnet_app[1]  # Changed to use private subnet
  sg_id             = module.security_groups.web_sg_id
  iam_role_name     = module.iam.instance_profile_name
  instance_name     = "WebTierInstance"
  user_data_script  = "launch_web-tier.sh"
  enable_public_ip  = false
  depends_on_resource = [module.internal_alb, module.backend_ec2]
}

# External ALB Module
module "external_alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnet
  sg_id             = module.security_groups.web_alb_sg_id
  instance_id       = module.frontend_ec2.instance_id
  name              = "Web-External-ALB"
  internal          = false
  port              = 80
  health_check_path = "/"
}
