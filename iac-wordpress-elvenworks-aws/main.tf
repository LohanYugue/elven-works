terraform {
  backend "s3" {
    bucket = "lohan-terraform-state"
    key    = "iac-wordpress-elvenworks-aws/terraform.state"
    region = "us-east-1"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  vpc_range_ip = var.vpc_range_ip
}

module "ec2" {
  source        = "./modules/ec2"
  instance_name = var.instance_name
  subnet_id     = module.vpc.subnet_id
  vpc_id        = module.vpc.vpc_id
  elb_sg_id     = module.load_balancer.elb_sg_id
}

module "database" {
  source      = "./modules/rds"
  rds_name    = var.rds_name
  db_name     = var.db_name
  subnet_id   = module.vpc.subnet_id
  subnet_id_2 = module.vpc.subnet_id_2
  ec2_sg_id   = module.ec2.ec2_sg_id
  aws_region  = var.aws_region
  vpc_id      = module.vpc.vpc_id
}

module "load_balancer" {
  source        = "./modules/elb"
  elb_name      = var.elb_name
  instance_name = var.instance_name
  ec2_id        = module.ec2.ec2_id
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.subnet_id
  subnet_id_2   = module.vpc.subnet_id_2
}