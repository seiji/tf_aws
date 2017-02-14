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
  tags { Name = "${var.name}-igw" }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  tags { Name = "${var.name}-default" }
}

resource "aws_security_group" "nat" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.main.id}"
  tags { Name = "${var.name}-nat" }
}

data "aws_ami" "nat" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "architecture" values = ["x86_64"] }
  filter { name = "root-device-type" values = ["ebs"] }
  filter { name = "name" values = ["amzn-ami-vpc-nat*"] }
  filter { name = "virtualization-type" values = ["hvm"] }
  filter { name = "block-device-mapping.volume-type" values = ["gp2"] }
}

resource "aws_instance" "nat" {
  ami = "${data.aws_ami.nat.id}"
  availability_zone = "${var.azs[count.index]}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.nat.id}"]
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  tags { Name = "${var.name}-nat" }
  count = "${length(var.public_subnets)}"
  source_dest_check = false
  key_name = "${var.key_name}"
}

resource "aws_eip" "nat" {
  vpc = true
  count = "${length(var.public_subnets)}"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = "${element(aws_instance.nat.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
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
  instance_id = "${element(aws_instance.nat.*.id, count.index)}"
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

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.main.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags { Name = "${var.name}-default" }
}
