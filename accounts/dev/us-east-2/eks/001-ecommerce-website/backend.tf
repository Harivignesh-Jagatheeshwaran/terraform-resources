terraform {
  backend "s3" {
    bucket       = "tf-statemanagement-dataplatform-dev"
    key          = "dataplatform/dev/us-east-2/001-ecommerce-website/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true  # Enables native S3 locking
  }
}