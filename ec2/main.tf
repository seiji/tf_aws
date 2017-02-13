resource "aws_instance" "ec2_instance" {
  count = "${var.number_of_instances}"
  ami = "${var.ami}"
  ebs_optimized = "${var.ebs_optimized}"
  disable_api_termination = "${var.disable_api_termination}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  subnet_id = "${var.subnet_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  // user_data = "${file(var.user_data)}"
  tags {
    created_by = "${lookup(var.tags,"created_by")}"
    Name = "${var.name}-${count.index}"
  }
}
