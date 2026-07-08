# 1. The CloudFront URL (The most important one!)
output "cloudfront_domain_name" {
  description = "The URL you will use to visit your website"
  value       = "https://${aws_cloudfront_distribution.tf_cloudfront_distribution}"
}

# 2. The exact CloudFront Distribution ID
output "cloudfront_distribution_id" {
  description = "Useful if you ever need to manually invalidate the cache"
  value       = aws_cloudfront_distribution.tf_cloudfront_distribution.id
}

# 3. The actual S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the S3 bucket created by Terraform"
  value       = aws_s3_bucket.terrafrom_s3_bucket_cdn.bucket
}