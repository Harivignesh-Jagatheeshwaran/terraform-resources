terraform {
  backend "s3" {
    bucket       = "tf-statemanagement-dataplatform-staging"
    key          = "dataplatform/stg/us-east-2/vpc/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true # Enables native S3 locking
  }
}