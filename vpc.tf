resource "aws_vpc" "workshop" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
}
