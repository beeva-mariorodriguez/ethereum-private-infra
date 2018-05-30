terraform {
  backend "s3" {
    bucket = "beevalabs-terraform-state"
    key    = "private_ethereum_infra_v2"
    region = "us-east-1"
  }
}
