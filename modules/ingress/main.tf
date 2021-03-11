# Reserve Elastic IP for NLB

resource "aws_eip" "this" {
  count = var.number_of_eips
  vpc               = var.vpc
  tags = var.tags
}


module "nlb" {
  source             = "../terraform-aws-lb"
  enable             = true
  name               = var.loadbalancer_name
  load_balancer_type = "network"
  internal           = false
  subnets = var.number_of_eips == 0 ? var.subnet_ids : null
  vpc_id             = var.vpc_id
  tags                 = var.tags

  subnet_mapping = var.number_of_eips > 0 ? flatten([
      for k,v in zipmap(aws_eip.this.*.id,var.subnet_ids): {
          subnet_id = v
          allocation_id = k
      }
  ]) : []

  ### For Target Groups
  target_groups = var.target_groups
  http_tcp_listeners = var.http_tcp_listeners
  depends_on = [
    aws_eip.this
  ]


  
}

### Needs review
resource "aws_lb_target_group_attachment" "b2b_nlb_prove_lower_tga" {
    count = length(var.target_ips)
    target_group_arn = join("", module.nlb.target_group_arns)
    target_id = var.target_ips[count.index]
    availability_zone = "all"
    port             = 443
}
