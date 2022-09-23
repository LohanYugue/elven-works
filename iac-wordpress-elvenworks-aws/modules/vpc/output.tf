output "subnet_id" {
    value = aws_subnet.public.id
}

output "subnet_id_2" {
    value = aws_subnet.public-1b.id
}

output "vpc_id" {
    value = aws_vpc.main.id
}