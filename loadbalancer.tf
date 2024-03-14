
data "aws_elb" "elbfood" {
  name = var.lb_name
}

resource "aws_lb_listener" "nlb_listener_https" {
  load_balancer_dns_name = ae2ffedd0f3594043b798c79362e7157-1561109267.us-east-1.elb.amazonaws.com
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  
  default_action {
    type             = "forward"
    
  }
}
