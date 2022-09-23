resource "aws_db_instance" "default" {
  identifier           = var.rds_name
  allocated_storage    = 10
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.rds.id ]
#   availability_zone    = var.aws_region
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [ var.subnet_id, var.subnet_id_2 ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds_security_group"
  description = "RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ var.ec2_sg_id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "rds_security_group"
  }

}

resource "local_file" "conf_wp_config" {  
  filename = "./ansible/roles/wordpress/files/wp-config.php"
  content = templatefile("./ansible/roles/wordpress/files/wp-config.php", { RDS_HOST = aws_db_instance.default.address} )
} 

resource "local_file" "conf_db_wordpress" {  
  filename = "./ansible/roles/wordpress/tasks/main.yml"
  content = templatefile("./ansible/roles/wordpress/tasks/main.yml", { RDS_HOST = aws_db_instance.default.address} )
} 