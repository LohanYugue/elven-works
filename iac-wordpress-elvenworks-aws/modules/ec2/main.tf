data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS-7-2111-20220825_1.x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.centos.id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name = aws_key_pair.deployer.id
  # security_groups = [ aws_security_group.default.id ]
  vpc_security_group_ids = [ aws_security_group.default.id ]

  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "lohan-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7jTPG8HDVdxsKDygnRi8rEfjsOi0Xt02Zpz9dXRPLJ6DR1kf24yh2flAkL7czDD8Z6fcckxePmMPObdzXhNvH3jxdevy0CMypr+/BklDfZLKj+6gCuzx/Lwne8WXwe+wV4toyA1U2yMn9BHHlyWWMlWn0pm3Z7nkf12w7HbcrhrFmcnlc2r6yRU8tPe5RAE5u2QokkF+4FEoDvRbMuz8T7yyANhXW1ZjNaaHhx/YxXM/fihicUpYIbOpUoOYFdc6eoowsw7Zs58ldnDf6NHrwg5wBCIsjgSEqFLCyMOAd9q2xhsHjcgQ9A4eIMPPtl8MnDhS5CuwxikctWBcdfeE6ZmUPIDemDF3Ygl02mqbBJym5Ulh2cb11nPaTEChHDZYRYfL109968NZHXkMzWmhvz4FW7oVBwT0POogEsysW9cn+PzDF41H9BalLvvf5YWNCjP2iwcNWXOCec5U5PKZRSbePVVp36cSUTmzOk9zUhP9gLlbmOkHmV7L9RQ8NbJ0= lohan@tc"
}

resource "aws_security_group" "default" {
  name        = "default_security_group"
  description = "Allow My IP"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Meu IP"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["186.220.37.61/32"]
  }

  ingress {
    description      = "Load Balancer"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [ var.elb_sg_id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "default_security_group"
  }
}

resource "local_file" "ip_ec2" {  
  filename = "./ansible/hosts"
  content = templatefile("./ansible/hosts", { IP_EC2 = aws_instance.web.public_ip} )
} 