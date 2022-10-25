locals {
  region                       = "us-east-1"
  mockinfra_availability_zones = ["${local.region}a", "${local.region}b", "${local.region}c"]
}

########################
# Call Module Networking
########################
module "Networking" {
  source               = "../modules/Networking"
  environment          = "MockInfra"
  vpc_cidr             = "10.150.0.0/16"
  public_subnets_cidr  = ["10.150.1.0/24"]
  private_subnets_cidr = ["10.150.10.0/24", "10.150.20.0/24"]
  availability_zones   = local.mockinfra_availability_zones

}


########################
# Call WebServers Module
########################

module "WebServers" {

  source              = "../modules/WebServers"
  ami                 = "ami-08c40ec9ead489470"
  instance_type       = "t2.micro"
  key_name            = "vockey"
  security_groups     = [aws_security_group.webserver_sg.id]
  security_groups_elb = [aws_security_group.webserver_sg.id]
}

##########################
# WebServers SecurityGroup
##########################
resource "aws_security_group" "webserver_sg" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" => Actually attached but not recognized cause of the module
  name        = "webservers_sg"
  description = "Security group for webservers"
}
resource "aws_security_group_rule" "allow_http" {
  description       = "Allow HTTP access from company s internal network"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["176.147.76.8/32"]
  security_group_id = aws_security_group.webserver_sg.id
}
resource "aws_security_group_rule" "allow_ssh" {
  description       = "Allow SSH access to DevOps team"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["176.147.76.8/32"]
  security_group_id = aws_security_group.webserver_sg.id
}
resource "aws_security_group_rule" "egress_all" {
  description       = "Egress rules all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}



########################
# Create EC2 Resources
########################
# resource "aws_instance" "webserver" {
#   #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
#   ami                         = var.ami
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   associate_public_ip_address = var.associate_public_ip_address
#   subnet_id                   = var.subnet_id
#   security_groups             = var.security_groups
#   ebs_optimized               = true
#   monitoring                  = true

#   metadata_options {
#     http_endpoint = "enabled"
#     http_tokens   = "optional"

#   }

#   root_block_device {
#     encrypted  = true
#     kms_key_id = aws_kms_key.a.id
#   }

# }
