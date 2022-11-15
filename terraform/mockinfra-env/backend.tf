terraform {
  backend "remote" {
    organization = "mysticx"

    workspaces {
      name = "TP-cloud-aws-5IRC"
    }
  }
}



# terraform {
#   backend "s3" {
#     bucket = "mockinfraprojectcpe"
#     key    = "MockInfraProjectCpe/backup_Tfstate"
#     region = "us-east-1"
#   }
# }
