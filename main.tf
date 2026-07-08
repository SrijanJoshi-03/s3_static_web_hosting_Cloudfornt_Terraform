resource "aws_s3_bucket" "terrafrom_s3_bucket_cdn" {
  bucket = var.s3_origin_bucket.name
  tags = {
    Environment = var.s3_origin_bucket.tags.Environment
    Project     = var.s3_origin_bucket.tags.Project
  }
}

data "aws_iam_policy_document" "terraform_origin_access_identity" {
  statement {
    sid    = "Allow CloudFront to read form the orign bucket"
    effect = "Allow"
    principals {
      type        = "service"
      identifiers = ["cloudfornt.amazonaws.com"]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.terrafrom_s3_bucket_cdn.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "tf_origin_bucket_policy" {
  bucket = aws_s3_bucket.terrafrom_s3_bucket_cdn.bucket
  policy = data.aws_iam_policy_document.terraform_origin_access_identity.json
}

resource "aws_cloudfront_origin_access_control" "tf_origin_access_control" {
  name                              = "tf_orign_access_control"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}

resource "aws_cloudfront_distribution" "tf_cloudfront_distribution" {
  origin {
    domain_name              = aws_s3_bucket.terrafrom_s3_bucket_cdn.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.tf_origin_access_control.id
    origin_id                = local.s3_origin_id
  }
  enabled             = true
  is_ipv6_enabled     = false
  comment             = "This is a terraform cloudfront distribution"
  default_root_object = "index.html"
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  ordered_cache_behavior {
    path_pattern = "/"
    allowed_methods = ["GET","HEAD","OPTIONS"]
    cached_methods = ["GET","HEAD","OPTIONS"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      headers = ["Orign"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    path_pattern = "/hello"
    allowed_methods = ["GET","HEAD","OPTIONS"]
    cached_methods = ["GET","HEAD","OPTIONS"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      headers = ["Orign"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["AU","US","IN"]
    }
  }
  tags = {
    Environment = var.s3_origin_bucket.tags.Environment
    Project     = var.s3_origin_bucket.tags.Project
  }
  viewer_certificate {
  cloudfront_default_certificate = true
}

}

resource "aws_s3_object" "tf_index_html"{
    bucket = aws_cloudfront_distribution.tf_cloudfront_distribution.id
    key = "index.html"
    source = "./assets/index.html"
    content_type = "text/html"
}