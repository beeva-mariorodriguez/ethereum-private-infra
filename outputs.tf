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
