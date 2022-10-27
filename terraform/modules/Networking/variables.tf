variable "availability_zones" {
  type        = list(any)
  description = "AZ in which all the resources will be deployed"
}

variable "environment" {
  type        = string
  description = "Deployment Environment"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
}


variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the vpc"
}
