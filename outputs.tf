output "bootnode_public_ip" {
  value = ["${aws_instance.ethereum_bootnode.public_ip}"]
}

output "node_public_ip" {
  value = ["${aws_instance.ethereum_node.*.public_ip}"]
}
