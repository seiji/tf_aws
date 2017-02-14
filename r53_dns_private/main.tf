resource "aws_route53_zone" "private" {
  name = "${var.name}"
  vpc_id =
  tags { Name = "${var.name}" }
}

