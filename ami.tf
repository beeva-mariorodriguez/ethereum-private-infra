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
