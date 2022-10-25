terraform {
  backend "s3" {
    bucket = "mockinfraprojectcpe"
    key    = "MockInfraProjectCpe/backup_Tfstate"
    region = "us-east-1"
  }
}
