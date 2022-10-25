
##################
#Networking Module
##################
output "vpc_id" {

  value = module.Networking.vpc_id
}

output "public_subnets_id" {

  value = module.Networking.public_subnets_id
}

output "private_subnets_id" {

  value = module.Networking.private_subnets_id

}


output "default_sg_id" {

  value = module.Networking.default_sg_id

}

output "webser_sg_id" {

  value = aws_security_group.webserver_sg.id
}

##################
#Webservers Module
##################
output "elb_dns_name" {

  value = module.WebServers.Dns_Elb

}
