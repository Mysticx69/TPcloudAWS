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
  public_subnets_cidr  = ["10.150.1.0/24", "10.150.2.0/24"]
  private_subnets_cidr = ["10.150.10.0/24", "10.150.20.0/24"]
  availability_zones   = local.mockinfra_availability_zones


}


########################
# Call WebServers Module
########################
module "WebServers" {

  source                      = "../modules/WebServers"
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  security_groups             = [aws_security_group.webserver_sg.id]
  security_groups_elb         = [aws_security_group.elb_sg.id]
  vpc_zone_identifier         = [element(element(module.Networking.public_subnets_id, 1), 0), element(element(module.Networking.public_subnets_id, 1), 1)]
  subnets_elb                 = [element(element(module.Networking.public_subnets_id, 1), 0), element(element(module.Networking.public_subnets_id, 1), 1)]
  associate_public_ip_address = true
}

##########################
# WebServers SecurityGroup
##########################
resource "aws_security_group" "elb_sg" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" => Actually attached but not recognized cause of the module
  name        = "webservers_sg"
  description = "Security group for webservers"
  vpc_id      = module.Networking.vpc_id
}
resource "aws_security_group_rule" "allow_http" {
  description       = "Allow HTTP access from company s internal network"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["176.147.76.8/32"]
  security_group_id = aws_security_group.elb_sg.id
}
resource "aws_security_group_rule" "allow_ssh" {
  description       = "Allow SSH access to DevOps team"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["176.147.76.8/32"]
  security_group_id = aws_security_group.elb_sg.id
}
resource "aws_security_group_rule" "egress_all" {
  description       = "Egress rules all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_sg.id
}


resource "aws_security_group" "webserver_sg" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" => Actually attached but not recognized cause of the module
  name        = "webservers_sg"
  description = "Security group for webservers"
  vpc_id      = module.Networking.vpc_id
}
resource "aws_security_group_rule" "allow_http" {
  description       = "Allow HTTP access from ELB only"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_security_group.elb_sg.id]
  security_group_id = aws_security_group.webserver_sg.id
}
resource "aws_security_group_rule" "allow_ssh" {
  description       = "Allow SSH access from ELB only"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_security_group.elb_sg.id]
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
