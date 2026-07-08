terraform {
  backend "s3" {
    bucket       = "remote-backend-for-terraform-statefile-practice-2026"
    key          = "project/terraform"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = false
  }
}