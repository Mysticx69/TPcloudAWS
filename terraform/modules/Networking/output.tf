output "default_sg_id" {
  value       = aws_default_security_group.default.id
  description = "Output the default security group id"
}

output "private_subnets_id" {
  value       = [aws_subnet.private_subnet.*.id]
  description = "Output all private subnets ids in a list"
}

output "private_subnets_cidr" {
  value       = [aws_subnet.private_subnet.*.cidr_block]
  description = "Output all CIDR block of private subnets in a list"
}

output "public_subnets_cidr" {
  value       = [aws_subnet.public_subnet.*.cidr_block]
  description = "Output all CIDR block of public subnets in a list"
}

output "public_subnets_id" {
  value       = [aws_subnet.public_subnet.*.id]
  description = "Output all public subnets ids in a list"
}

output "vpc_cidr" {
  value       = aws_vpc.vpc.cidr_block
  description = "Output the CIDR block of VPC"
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "Output the VPC id"
}
