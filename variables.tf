variable "subnet_name" {
  description = "Name of the subnet to use for the NIC. Has to be a part of the network referenced in var.vnet_name"
  type        = string
}

variable "vnet_name" {
  description = "Name of the network to use for the NIC. Should have the var.subnet_name subnet contained within"
  type        = string
}
