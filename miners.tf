resource "aws_instance" "ethereum_miner" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "${var.keyname}"
  count         = 1
  depends_on    = ["aws_instance.ethereum_bootnode"]

  tags {
    Name = "miner"
  }

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
  ]

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
      "/tmp/setup-vm.sh miner",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}
