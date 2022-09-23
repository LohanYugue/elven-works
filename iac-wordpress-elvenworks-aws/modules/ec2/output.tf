output "ec2_id" {
    value = aws_instance.web.id
}

output "ec2_sg_id" {
    value = aws_security_group.default.id  
}