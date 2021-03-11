variable "enable" {
  type        = bool
  description = "Controls if the Load Balancer should be created"
  default     = true
}

variable "name" {
  type        = string
  description = "(Required) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb"
}

variable "load_balancer_type" {
  type        = string
  description = "(Optional)The type of load balancer to create. Possible values are application or network."
  default     = "application"
}

variable "internal" {
  type        = bool
  description = "(Optional) If true, the LB will be internal."
  default     = true
}

variable "security_groups" {
  type        = list(string)
  description = "(Optional) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application."
  default = [

  ]
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application."
  default     = false
}

variable "access_logs" {
  type        = map(string)
  description = "(Optional) An Access Logs block. Access Logs documented below."
  default = {

  }
}

variable "subnets" {
  type        = list(string)
  description = "(Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource."
  default     = null
}

variable "subnet_mapping" {
  type        = list(map(string))
  description = "(Optional) A subnet mapping block as documented below."
  default = [

  ]
}

variable "idle_timeout" {
  type        = number
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = 60
}

variable "enable_deletion_protection" {
  type        = bool
  description = " (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "(Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = false
}

variable "enable_http2" {
  type        = bool
  description = "(Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true."
  default     = true
}

variable "ip_address_type" {
  type        = string
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  default     = "ipv4"
}

####################################################################
variable "extra_ssl_certs" {
  type        = list(map(string))
  description = "(Optional) A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward)."
  default     = []
}

variable "https_listeners" {
  type        = any
  description = "(Optional) A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])"
  default     = []
}

variable "http_tcp_listeners" {
  type        = any
  description = "(Optional) A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  default     = []
}

variable "https_listener_rules" {
  type        = any
  description = "(Optional) A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  default     = []
}

variable "listener_ssl_policy_default" {
  type        = string
  description = "(Optional) The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "load_balancer_create_timeout" {
  type        = string
  description = "(Optional) Timeout value when creating the ALB."
  default     = "10m"
}

variable "load_balancer_delete_timeout" {
  type        = string
  description = "(Optional) Timeout value when deleting the ALB."
  default     = "10m"
}

variable "load_balancer_update_timeout" {
  type        = string
  description = "(Optional) Timeout value when updating the ALB."
  default     = "10m"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to add to all resources"
  default = {

  }
}

variable "target_groups" {
  type        = any
  description = "(Optional) A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  default = [

  ]
}

variable "vpc_id" {
  type        = string
  description = "(Optional) VPC id where the load balancer and other resources will be deployed."
  default     = null
}
