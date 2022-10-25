resource "aws_elb" "ELB_Webservers" {
  #checkov:skip=CKV_AWS_127: "Ensure that Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager"
  name            = "ELB-Webservers"
  security_groups = var.security_groups_elb
  subnets         = var.subnets_elb

  access_logs {
    bucket = aws_s3_bucket.elb_logs.bucket

  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
}

data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket_public_access_block" "block_public_policy" {

  bucket                  = aws_s3_bucket.elb_logs.bucket
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.elb_logs.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.elb_logs.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "elb_logs" {
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  bucket = "elblogsawscloudproject"

  policy = <<POLICY

{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::elblogsawscloudproject/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}
