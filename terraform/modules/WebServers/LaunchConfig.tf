resource "aws_launch_configuration" "lauch_cfg_asg" {

  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  name                        = "webservers_launch"
  image_id                    = var.ami
  instance_type               = var.instance_type
  security_groups             = var.security_groups
  key_name                    = var.key_name
  user_data                   = file("/home/user/dev/TPcloudAWS/terraform/modules/WebServers/scripts/webservers.sh")
  associate_public_ip_address = var.associate_public_ip_address



  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"

  }

  root_block_device {
    encrypted = true
  }




}
