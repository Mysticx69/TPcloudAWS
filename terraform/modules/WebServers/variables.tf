
variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public ip address with an instance in a VPC."
}

variable "ami" {
  type        = string
  description = "AMI to use for the instance"
}

variable "instance_type" {
  type        = string
  description = " Instance type to use for the instance."
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instance"
}

variable "security_groups" {
  type        = set(string)
  description = "List of security group IDS to associate with."
}

variable "security_groups_elb" {
  type        = set(string)
  description = "List of security group IDS to associate with."
}

variable "subnets_elb" {
  type        = list(string)
  description = "A list of subnet IDs to attach to the ELB."
}

variable "vpc_zone_identifier" {
  type        = list(string)
  description = " List of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside"
}
