resource "aws_security_group" "main" {
  name = "${var.name}"
  description = "Security Group ${var.name}"
  vpc_id = "${var.vpc_id}"
  tags { Name = "${var.name}" }
}

resource "aws_security_group_rule" "mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  cidr_blocks              = ["${var.source_cidr_block}"]
  security_group_id        = "${aws_security_group.main.id}"
}
