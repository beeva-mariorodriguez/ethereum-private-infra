resource "aws_instance" "ethereum_proxy" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "${var.keyname}"
  depends_on    = ["aws_instance.ethereum_bootnode"]

  tags {
    Name = "proxy"
  }

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
    "${aws_security_group.ethereum_proxy.id}",
  ]

  provisioner "file" {
    source      = "files/proxy.conf"
    destination = "/tmp/default.conf"
  }

  provisioner "file" {
    source      = "keys/boot.pub"
    destination = "/tmp/boot.pub"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "file" {
    source      = "files/genesis.json"
    destination = "/tmp/genesis.json"
  }

  provisioner "remote-exec" {
    inline = [
      "export ETHEREUM_IMAGE=${var.ethereum_image}",
      "export ETHERBASE=${var.etherbase}",
      "export BOOTNODE_IP=${aws_instance.ethereum_bootnode.private_ip}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh proxy",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}

resource "aws_security_group" "ethereum_proxy" {
  name   = "ethereum_proxy"
  vpc_id = "${aws_vpc.ethereum.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
