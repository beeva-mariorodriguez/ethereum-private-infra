terraform {
  backend "s3" {
    bucket = "beevalabs-terraform-state"
    key    = "private_ethereum_infra"
    region = "us-east-1"
  }
}
