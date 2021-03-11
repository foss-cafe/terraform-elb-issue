module "example_ingress_nlb_module" {
  source            = "./modules/ingress"
  number_of_eips    = 2
  tags              = {
      "test" = "12345"
  }
  loadbalancer_name = "ingress-nlb-test"
  subnet_ids        = var.subnet_ids
  
  vpc_id = var.vpc_id
  target_groups = [
    {
      name        = "ingress-module-tg"
      backend_port        = "443"
      backend_protocol    = "tcp"
      target_type = "ip"
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        port                = "traffic-port"
        protocol            = "TCP"
        unhealthy_threshold = 3
      }
      stickiness = {
        cookie_duration = 0
        enabled         = false
        type            = "source_ip"
      }
      
    },

  ]
  target_ips = ["10.10.10.10", "10.10.10.11"]
  http_tcp_listeners = [
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    },

  ]
}
