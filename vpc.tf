resource "aws_vpc" "ethereum" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
}
