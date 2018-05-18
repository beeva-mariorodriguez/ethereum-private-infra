resource "aws_security_group" "allow_outbound" {
  name   = "allow_outbound"
  vpc_id = "${aws_vpc.workshop.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name   = "ssh"
  vpc_id = "${aws_vpc.workshop.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ethereum_bootnode" {
  name   = "ethereum_bootnode"
  vpc_id = "${aws_vpc.workshop.id}"

  ingress {
    from_port = 30301
    to_port   = 30301
    protocol  = "udp"

    # security_groups = ["${aws_security_group.ethereum_node.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ethereum_node" {
  name   = "ethereum_node"
  vpc_id = "${aws_vpc.workshop.id}"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    # self      = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30303
    to_port   = 30303
    protocol  = "tcp"

    # self      = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30303
    to_port   = 30303
    protocol  = "udp"

    # self      = true
    cidr_blocks = ["0.0.0.0/0"]
  }
}
