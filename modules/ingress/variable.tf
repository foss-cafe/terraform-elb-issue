variable "number_of_eips" {
    type = number
  description = "Number of elastic IPs needed"
  default = 0
}

variable "vpc" {
    type = bool
  description = "description"
  default     = true
}

variable "tags" {
    type = map(string)
  description = "description"
  default     = {

  }
}

variable "subnet_ids" {
    type  = list(string)
  description = "Subnet IDs for Subnet Mapping"
}

variable "target_groups" {
    type = any
  description = "description"
  default     = [

  ]
}

variable "vpc_id"{
  type =string
}

variable "loadbalancer_name" {
    type = string
}

variable "target_ips"{
  type = list(string)
}

variable "http_tcp_listeners" {
  description = "description"
}
