
data "aws_elb" "elbfood" {
  name = var.lb_name
}

resource "aws_lb_listener" "nlb_listener_https" {
  load_balancer_arn = data.aws_lb.elbfood.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}
