# provider

provider "aws" {
  version = "~> 1.3"
  region  = "${var.region}"
}

# variables

variable "keyname" {
  default = "ethereum"
}

variable "region" {
  default = "us-east-2"
}

variable "ethereum_image" {
  default = "ethereum/client-go:alltools-v1.8.1"
}

variable "etherbase" {
  default = "0000000000000000000000000000000000000001"
}

# VPC

resource "aws_vpc" "ethereum" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
}

# network

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.ethereum.id}"
}

resource "aws_route" "r" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_vpc.ethereum.default_route_table_id}"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_subnet" "ethereum" {
  vpc_id                  = "${aws_vpc.ethereum.id}"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
}

# security groups

resource "aws_security_group" "allow_outbound" {
  name   = "allow_outbound"
  vpc_id = "${aws_vpc.ethereum.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name   = "ssh"
  vpc_id = "${aws_vpc.ethereum.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ethereum_node" {
  name   = "ethereum_node"
  vpc_id = "${aws_vpc.ethereum.id}"

  ingress {
    from_port = 30303
    to_port   = 30303
    protocol  = "tcp"
    self      = true

    // cidr_blocks = ["${aws_subnet.ethereum.cidr_block}"]
  }

  ingress {
    from_port = 30303
    to_port   = 30303
    protocol  = "udp"
    self      = true

    // cidr_blocks = ["${aws_subnet.ethereum.cidr_block}"]
  }
}

# AMI

data "aws_ami" "stretch" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64*"]
  }
}

data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }
}

data "aws_ami" "bionic" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"]
  }
}

# output

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "proxy_public_ip" {
  value = "${aws_instance.ethereum_proxy.public_ip}"
}

output "etherbase" {
  value = "${var.etherbase}"
}

output "ethereum_image" {
  value = "${var.ethereum_image}"
}

# backend

terraform {
  backend "s3" {
    bucket = "beevalabs-terraform-state"
    key    = "private_ethereum_infra_v2"
    region = "us-east-1"
  }
}
