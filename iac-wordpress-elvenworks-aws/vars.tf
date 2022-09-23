#Global
variable "aws_region" {
  default = "us-east-1"
}

#VPC
variable "vpc_range_ip" {
    default = "10.0.0.0/16"
}

#EC2
variable "instance_name" {
    default = "wordpress-1"
}

#RDS
variable "rds_name" {
    default = "mysql-blog-wordpress"
}

variable "db_name" {
    default = "wordpress"
}

#Load Balancer
variable "elb_name" {
    default = "elb-wordpress"
}