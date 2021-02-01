########################
# CLOUDFRONT RESOURCES #
########################

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${local.prefix}-app"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.cinema_app_s3_bucket.bucket_regional_domain_name
    origin_id   = "default-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"

  aliases = ["cinema${terraform.workspace == "master" ? "" : "-${terraform.workspace}"}.corbet-it.fr"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "default-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 300

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.common_tags

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:${var.cloudfront_certificate}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}
