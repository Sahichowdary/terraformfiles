
data "aws_elb" "elbfood" {
  name = var.lb_name
}


data "aws_elb" "elbfood2" {
  name = var.lb_name2
}

