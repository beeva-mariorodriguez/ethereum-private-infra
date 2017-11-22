resource "aws_instance" "ethereum_bootnode" {
  ami           = "${data.aws_ami.stretch.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "mrc"

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_bootnode.id}",
  ]
}

resource "aws_instance" "ethereum_node" {
  ami           = "${data.aws_ami.stretch.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "mrc"
  count         = 2

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
  ]
}
