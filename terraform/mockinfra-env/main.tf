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

#####################
# Create Bastion Host
#####################
resource "aws_instance" "bastion" {
  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  #checkov:skip=CKV_AWS_135: "Ensure that EC2 is EBS optimized" => not supported with labs account
  #checkov:skip=CKV_AWS_126: "Ensure that detailed monitoring is enabled for EC2 instances" => not supported with labs account
  ami             = "ami-08c40ec9ead489470"
  instance_type   = "t2.micro"
  key_name        = "vockey"
  security_groups = [aws_security_group.bastionhost_sg.id]
  subnet_id       = element(element(module.Networking.public_subnets_id, 1), 0)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.key1.id

  }

  tags = {
    Name = "Bastion Host"
  }
}

#############################
# Create EIP for Bastion Host
#############################
resource "aws_eip" "bastion_eip" {
  #checkov:skip=CKV2_AWS_19: "Ensure that all EIP addresses allocated to a VPC are attached to EC2 instances" => EIP is attached but not recognized cause bastion host  not created atm
  instance = aws_instance.bastion.id
}

#####################
# Create Backend host
#####################
resource "aws_instance" "backend_host" {
  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  #checkov:skip=CKV_AWS_135: "Ensure that EC2 is EBS optimized" => not supported with labs account
  #checkov:skip=CKV_AWS_126: "Ensure that detailed monitoring is enabled for EC2 instances" => not supported with labs account
  ami             = "ami-08c40ec9ead489470"
  instance_type   = "t2.micro"
  key_name        = "vockey"
  security_groups = [aws_security_group.backendhost_sg.id]
  subnet_id       = element(element(module.Networking.private_subnets_id, 1), 0)
  user_data       = file("/home/user/dev/TPcloudAWS/terraform/modules/WebServers/scripts/backend.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.key1.id
  }

  tags = {
    Name = "backend_host"
  }
}

######################
# Create Database host
######################
resource "aws_instance" "mysql_db" {
  #checkov:skip=CKV_AWS_79:"Ensure Instance Metadata Service Version 1 is not enabled"
  #checkov:skip=CKV_AWS_135:"Ensure that EC2 is EBS optimized" => not supported with labs account
  #checkov:skip=CKV_AWS_126:"Ensure that detailed monitoring is enabled for EC2 instances" => not supported with labs account
  ami             = "ami-08c40ec9ead489470"
  instance_type   = "t2.micro"
  key_name        = "vockey"
  security_groups = [aws_security_group.mysql_sg.id]
  subnet_id       = element(element(module.Networking.private_subnets_id, 1), 1)
  user_data       = file("/home/user/dev/TPcloudAWS/terraform/modules/WebServers/scripts/mysql.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.key1.id
  }

  tags = {
    Name = "mysql_db"
  }
}

################
# Create KMS key
################
resource "aws_kms_key" "key1" {
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    "Name" = "KEY1"
  }
}

#####################################
# Elastic Load Balancer SecurityGroup
#####################################
resource "aws_security_group" "elb_sg" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" => Actually attached but not recognized cause of the module
  name        = "elb_sg"
  description = "Security group for ELB"
  vpc_id      = module.Networking.vpc_id
  tags = {
    "Name" = "ELB_SG"
  }
}

resource "aws_security_group_rule" "allow_http_elb_sg" {
  description       = "Allow HTTP access to ELB from company s internal network"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["13.66.128.0/17", "176.147.76.8/32"]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "allow_https_elb_sg" {
  description       = "Allow HTTPS access to ELB from company s internal network"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["13.66.128.0/17", "176.147.76.8/32"]
  security_group_id = aws_security_group.elb_sg.id
}


resource "aws_security_group_rule" "egress_datacenter_elb" {
  description       = "Allow Egress to companys Datacenter"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["13.104.208.64/27"]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "egress_webservers_elb" {
  description       = "Allow Egress to webservers"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [element(element(module.Networking.public_subnets_cidr, 1), 0), element(element(module.Networking.public_subnets_cidr, 1), 1)]
  security_group_id = aws_security_group.elb_sg.id
}

##########################
# WebServers SecurityGroup
##########################
resource "aws_security_group" "webserver_sg" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" => Actually attached but not recognized cause of the module
  name        = "webservers_sg"
  description = "Security group for webservers"
  vpc_id      = module.Networking.vpc_id
  tags = {
    "Name" = "Webservers_SG"
  }
}

resource "aws_security_group_rule" "allow_igress_elb_webservers" {
  description              = "Allow igress from ELB"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.elb_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "allow_igress_bastion_webservers" {
  description              = "Allow SSH igress from bastion host"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastionhost_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "egress_todatacenter_webservers" {
  description       = "Egress rule to companys datacenter"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["13.104.208.64/27"]
  security_group_id = aws_security_group.webserver_sg.id
}

############################
# Bastion Host SecurityGroup
############################
resource "aws_security_group" "bastionhost_sg" {
  name        = "bastionhost_sg"
  description = "Security Group For Bastion Host"
  vpc_id      = module.Networking.vpc_id
  tags = {
    "Name" = "Bastion_SG"
  }
}

resource "aws_security_group_rule" "allow_ssh_devops_bastionhost" {
  description       = "Allow SSH to bastion host from DevOps Team"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["13.67.153.32/27", "176.147.76.8/32"]
  security_group_id = aws_security_group.bastionhost_sg.id
}

resource "aws_security_group_rule" "egress_toservers_bastionhost" {
  description       = "Egress rule to all servers from bastion host"
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [module.Networking.vpc_cidr]
  security_group_id = aws_security_group.bastionhost_sg.id
}

#############################
# Backend Host SecurityGroup
#############################
resource "aws_security_group" "backendhost_sg" {
  name        = "backendhost_sg"
  description = "Security Group For Backend Host"
  vpc_id      = module.Networking.vpc_id
  tags = {
    "Name" = "BackendHost_SG"
  }
}

resource "aws_security_group_rule" "allow_ssh_bastion_backendhost" {
  description              = "Allow SSH from bastion host"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastionhost_sg.id
  security_group_id        = aws_security_group.backendhost_sg.id
}

resource "aws_security_group_rule" "allow_ingress_webservers_backendhost" {
  description              = "Allow Ingress to backend host from websevers hosts"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
  security_group_id        = aws_security_group.backendhost_sg.id
}

resource "aws_security_group_rule" "egress_todatabase_backendhost" {
  description       = "Egress rules all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${aws_instance.mysql_db.private_ip}/32"]
  security_group_id = aws_security_group.backendhost_sg.id
}

resource "aws_security_group_rule" "egress_todatacenter_backendhost" {
  description       = "Egress rules to companys datacenter"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["13.104.208.64/27"]
  security_group_id = aws_security_group.backendhost_sg.id
}

#############################
# Database Host SecurityGroup
#############################
resource "aws_security_group" "mysql_sg" {
  name        = "MySQL_sg"
  description = "Security Group For MySQL Host"
  vpc_id      = module.Networking.vpc_id
  tags = {
    "Name" = "MySQL_SG"
  }
}

resource "aws_security_group_rule" "allow_ssh_bastionhost_mysqlhost" {
  description              = "Allow SSH to mySQL host from bastion host"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastionhost_sg.id
  security_group_id        = aws_security_group.mysql_sg.id
}

resource "aws_security_group_rule" "allow_ingress_backendhost_mysqlhost" {
  description              = "Allow Ingress to mySQL host from backend host"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backendhost_sg.id
  security_group_id        = aws_security_group.mysql_sg.id
}

resource "aws_security_group_rule" "egress_datacenter_databasehost" {
  description       = "Egress to companys Datacenter"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["13.104.208.64/27"]
  security_group_id = aws_security_group.mysql_sg.id
}

#####################
# Public Subnets NACL
#####################
# resource "aws_network_acl" "nacl_public_subnets" {
#   vpc_id     = module.Networking.vpc_id
#   subnet_ids = module.Networking.public_subnets_id
# }

# resource "aws_network_acl_rule" "allow_http" {
#   network_acl_id = aws_network_acl.nacl_public_subnets.id
#   rule_number    = 10
#   protocol       = "tcp"
#   rule_action    = "allow"
#   from_port      = "80"
#   to_port        = "80"
# }

# resource "aws_network_acl_rule" "allow_https" {
#   network_acl_id = aws_network_acl.nacl_public_subnets.id
#   rule_number    = 20
#   protocol       = "tcp"
#   rule_action    = "allow"
#   from_port      = "443"
#   to_port        = "443"

# }

# resource "aws_network_acl_rule" "allow_ssh" {
#   network_acl_id = aws_network_acl.nacl_public_subnets.id
#   rule_number    = 30
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "13.67.153.32/27"
#   from_port      = "22"
#   to_port        = "22"
# }


# resource "aws_network_acl_rule" "allow_ssh_home" {
#   network_acl_id = aws_network_acl.nacl_public_subnets.id
#   rule_number    = 40
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "172.147.76.8/32"
#   from_port      = "22"
#   to_port        = "22"
# }


# resource "aws_network_acl_rule" "allow_traffic_return" {
#   network_acl_id = aws_network_acl.nacl_public_subnets.id
#   rule_number    = 50
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = "1024"
#   to_port        = "65535"
# }
