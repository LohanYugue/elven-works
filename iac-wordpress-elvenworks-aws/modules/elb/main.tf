resource "aws_elb" "bar" {
  name               = var.elb_name
#   availability_zones = [ "us-east-1a", "us-east-1b" ]
  internal           = false
  security_groups    = [ aws_security_group.load_balancer.id ]
  subnets            = [ var.subnet_id, var.subnet_id_2 ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/info.php"
    interval            = 30
  }

  instances                   = [ var.ec2_id ]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = var.elb_name
  }
}


resource "aws_security_group" "load_balancer" {
  name        = "elb_security_group"
  description = "Allow HTTP/HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "PING"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "elb_security_group"
  }
}