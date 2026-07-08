variable "s3_origin_bucket" {
  type = object({
    name = string
    tags = map(string)
  })
  default = {
    name = "terraform-s3-web-hosting-enabled-bucket-with-cloudfront"
    tags = {
      Environment = "production"
      Project     = "s3_web_hosting"
    }
  }
}