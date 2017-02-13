variable "name" {
  description = "Name for whole VPC"
}

variable "number_of_instances" {
  description = "Number of instance"
  default = 1
}

variable "ami" {
  description = "The AMI to use for the instance."
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default = false
}

variable "disable_api_termination" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default = false
}

variable "instance_type" {
  description = "The type of instance to start"
}

variable "key_name" {
  description = "The key name to use for the instance."
  default = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
  default = false
}

variable "vpc_security_group_ids" {
  type = "list"
  description = "A list of security group IDs to associate with."
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in."
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC. Boolean value."
  default = false
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  default = ""
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  default = true
}

variable "tags" {
	default = {
     created_by = "terraform"
  }
}
