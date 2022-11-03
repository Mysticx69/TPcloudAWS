resource "aws_elb" "ELB_Webservers" {
  #checkov:skip=CKV_AWS_127: "Ensure that Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager"
  name            = "ELB-mockinfrawebservers"
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

  tags = {
    "Name" = "ELB_mockinfra"
  }
}

##########################
# Fetch Elb Service Account
###########################
data "aws_elb_service_account" "main" {}

####################
# S3 Bucket For Logs
####################
resource "aws_s3_bucket" "elb_logs" {
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  bucket = "elblogsawscloudproject"
}

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

resource "aws_s3_bucket_policy" "S3_policy_for_elb" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = data.aws_iam_policy_document.S3_policy_for_elb.json
}

data "aws_iam_policy_document" "S3_policy_for_elb" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.elb_logs.arn,
      "${aws_s3_bucket.elb_logs.arn}/AWSLogs/*",
    ]
  }
}
