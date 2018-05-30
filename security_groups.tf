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
