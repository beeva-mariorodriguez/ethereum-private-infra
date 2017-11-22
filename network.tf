resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.workshop.id}"
}

resource "aws_route" "r" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_vpc.workshop.default_route_table_id}"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_subnet" "ethereum" {
  vpc_id                  = "${aws_vpc.workshop.id}"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
}
