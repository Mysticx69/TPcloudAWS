provider "aws" {
  region  = "us-east-1"
  profile = "default"

  default_tags {
    tags = {
      Authors     = "Antoine STERNA_Remi GRUFFAT"
      Project     = "Awscloudproject-5IRC"
      Environment = "MockInfrastructure"
      DeployedBy  = "Terraform"
    }
  }
}

terraform {
  required_version = "1.3.3"

  required_providers {
    aws = "~>4"
  }
}
