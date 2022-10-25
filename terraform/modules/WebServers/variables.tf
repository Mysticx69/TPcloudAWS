
variable "availability_zones" {

  description = "Choose AZ"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
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
