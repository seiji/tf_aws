resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  enable_dns_support = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  tags { Name = "${var.name}" }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count = "${length(var.private_subnets)}"
  tags { Name = "${var.name}-private" }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count = "${length(var.public_subnets)}"
  tags { Name = "${var.name}-public" }

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_eip" "nat" {
  vpc = true
  count = "${length(var.public_subnets)}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  count = "${length(var.public_subnets)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]
  tags { Name = "${var.name}-public" }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  tags { Name = "${var.name}-private" }
}

resource "aws_route" "nat_gateway" {
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
