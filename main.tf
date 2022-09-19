terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.31.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "networking" {
  source          = "./vpc"
  vpc_name        = "rds-demo-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_cidr_01  = "10.0.0.0/20"
  public_cidr_02  = "10.0.16.0/20"
  private_cidr_01 = "10.0.128.0/20"
  private_cidr_02 = "10.0.144.0/20"
}

module "ec2" {
  source              = "./ec2"
  vpc_id              = module.networking.vpc_id
  vpc_zone_identifier = [module.networking.public_subnet_01, module.networking.public_subnet_02]
}

module "rds" {
  source                  = "./rds"
  inbound_security_groups = [module.ec2.frontend_security_group]
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = [module.networking.private_subnet_01, module.networking.private_subnet_02]
}

