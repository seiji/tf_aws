variable "name" {
  description = "Name for whole VPC"
}

variable "cidr" {
  type = "string"
  description = "The CIDR block for the VPC"
}

variable "azs" {
  type = "list"
  description = "Availability Zones for the VPC"
}

variable "private_subnets" {
  type = "list"
  description = "CIDR for the private subnet"
}

variable "public_subnets" {
  type = "list"
  description = "CIDR for the public subnet"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true"
  default = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default = false
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default = []
}
