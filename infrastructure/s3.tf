################
# S3 RESOURCES #
################

resource "aws_s3_bucket" "cinema_app_s3_bucket" {
  bucket        = "${local.prefix}-app"
  acl           = "private"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning {
    enabled = true
  }

  tags = local.common_tags

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContentAndCircleCI",
    "Statement": [
        {
            "Sid": "CloudFrontPrivateContent",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.prefix}-app/*"
        },
        {
            "Sid": "CircleCI-Bucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::039509991122:user/cinema"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${local.prefix}-app"
        },
        {
            "Sid": "CircleCI-Objects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::039509991122:user/cinema"
            },
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${local.prefix}-app/*"
        }        
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "cinema_app_s3_bucket_acls" {
  bucket                  = aws_s3_bucket.cinema_app_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}