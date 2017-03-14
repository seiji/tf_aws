resource "aws_security_group" "main" {
  name = "${var.name}"
  description = "Security Group ${var.name}"
  vpc_id = "${var.vpc_id}"
  tags { Name = "${var.name}" }
}

resource "aws_security_group_rule" "redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  cidr_blocks              = ["${var.source_cidr_block}"]
  security_group_id        = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "redis_cluster" {
  type                     = "ingress"
  from_port                = 16379
  to_port                  = 16379
  protocol                 = "tcp"
  cidr_blocks              = ["${var.source_cidr_block}"]
  security_group_id        = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "redis_sentinel" {
  type                     = "ingress"
  from_port                = 26379
  to_port                  = 26379
  protocol                 = "tcp"
  cidr_blocks              = ["${var.source_cidr_block}"]
  security_group_id        = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["${var.source_cidr_block}"]
  security_group_id        = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "out" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = "${aws_security_group.main.id}"
}
