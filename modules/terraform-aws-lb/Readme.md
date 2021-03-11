# Terraform module for AWS Application and Network Load Balancer (ALB & NLB) 

## Usage

### Application Load Balancer

HTTP and HTTPS listeners with default actions:

```hcl
module "alb" {
  source  = "./"
  
  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

HTTP to HTTPS redirect and HTTPS cognito authentication:

```hcl
module "alb" {
  source  = "./"
  
  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name      = "pref-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      action_type          = "authenticate-cognito"
      target_group_index   = 0
      authenticate_cognito = {
        user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
        user_pool_client_id = "6oRmFiS0JHk="
        user_pool_domain    = "test-domain-com"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

Cognito Authentication only on certain routes, with redirects for other routes:

```hcl
module "alb" {
  source  = "./"
  
  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name      = "default-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port                 = 443
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 5000

      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/onboarding", "/docs"]
      }]
    },
    {
      https_listener_index = 0
      priority             = 2

      actions = [
        {
          type = "authenticate-cognito"

          user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
          user_pool_client_id = "6oRmFiS0JHk="
          user_pool_domain    = "test-domain-com"
        },
        {
          type               = "forward"
          target_group_index = 0
        }
      ]

      conditions = [{
        path_patterns = ["/protected-route", "private/*"]
      }]
    }
  ]
}
```

When you're using ALB Listener rules, make sure that every rule's `actions` block ends in a `forward`, `redirect`, or `fixed-response` action so that every rule will resolve to some sort of an HTTP response. Checkout the [AWS documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html) for more information.

### Network Load Balancer (TCP_UDP, UDP, TCP and TLS listeners)

```hcl
module "nlb" {
  source  = "./"
  
  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = "vpc-abcde012"
  subnets = ["subnet-abcde012", "subnet-bcde012a"]
  
  access_logs = {
    bucket = "my-nlb-logs"
  }

  target_groups = [
    {
      name             = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| aws | >= 2.54, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.54, < 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_logs | (Optional) An Access Logs block. Access Logs documented below. | `map(string)` | `{}` | no |
| drop\_invalid\_header\_fields | (Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application. | `bool` | `false` | no |
| enable | Controls if the Load Balancer should be created | `bool` | `true` | no |
| enable\_cross\_zone\_load\_balancing | (Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false. | `bool` | `false` | no |
| enable\_deletion\_protection | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| enable\_http2 | (Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true. | `bool` | `true` | no |
| extra\_ssl\_certs | (Optional) A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). | `list(map(string))` | `[]` | no |
| http\_tcp\_listeners | (Optional) A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| https\_listener\_rules | (Optional) A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]) | `any` | `[]` | no |
| https\_listeners | (Optional) A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index]) | `any` | `[]` | no |
| idle\_timeout | (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60. | `number` | `60` | no |
| internal | (Optional) If true, the LB will be internal. | `bool` | `true` | no |
| ip\_address\_type | (Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack | `string` | `"ipv4"` | no |
| listener\_ssl\_policy\_default | (Optional) The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html). | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| load\_balancer\_create\_timeout | (Optional) Timeout value when creating the ALB. | `string` | `"10m"` | no |
| load\_balancer\_delete\_timeout | (Optional) Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| load\_balancer\_type | (Optional)The type of load balancer to create. Possible values are application or network. | `string` | `"application"` | no |
| load\_balancer\_update\_timeout | (Optional) Timeout value when updating the ALB. | `string` | `"10m"` | no |
| name | (Required) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb | `string` | n/a | yes |
| security\_groups | (Optional) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application. | `list(string)` | `[]` | no |
| subnet\_mapping | (Optional) A subnet mapping block as documented below. | `list(map(string))` | `[]` | no |
| subnets | (Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource. | `list(string)` | `null` | no |
| tags | (Optional) A map of tags to add to all resources | `map(string)` | `{}` | no |
| target\_groups | (Optional) A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port | `any` | `[]` | no |
| vpc\_id | (Optional) VPC id where the load balancer and other resources will be deployed. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| this\_lb\_arn | The ID and ARN of the load balancer we created. |
| this\_lb\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| this\_lb\_dns\_name | The DNS name of the load balancer. |
| this\_lb\_id | The ID and ARN of the load balancer we created. |
| this\_lb\_zone\_id | The zone\_id of the load balancer to assist with creating DNS records. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO

- [ ] Support for LB traget group attachment