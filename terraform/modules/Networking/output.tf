
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets_id" {
  value = [aws_subnet.public_subnet.*.id]
}

output "public_subnets_cidr" {
  value = [aws_subnet.public_subnet.*.cidr_block]
}

output "private_subnets_id" {
  value = [aws_subnet.private_subnet.*.id]
}

output "default_sg_id" {
  value = aws_default_security_group.default.id
}
