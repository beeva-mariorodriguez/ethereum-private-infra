output "bastion_public_ip" {
  value = ["${aws_instance.bastion.public_ip}"]
}

output "bootnode_public_ip" {
  value = ["${aws_instance.ethereum_bootnode.public_ip}"]
}

output "node_public_ip" {
  value = ["${aws_instance.ethereum_node.*.public_ip}"]
}

output "etherbase" {
  value = ["${var.etherbase}"]
}

output "ethereum_image" {
  value = ["${var.ethereum_image}"]
}
