terraform {
  required_version = "1.3.3"
  required_providers {
    aws = "~>2.8"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"

}
