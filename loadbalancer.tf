
resource "aws_security_group" "nlb_sg" {
  name        = "nlb-sg"
  description = "Security group for NLB"
  vpc_id      = aws_vpc.private_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nlb-sg"
  }
}


# Create Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "poc-nlb"
  load_balancer_type = "network"
  subnets            = [aws_subnet.public-us-east-1a.id]
  security_groups    = [aws_security_group.nlb_sg.id]
}

# Create VPC security group for EKS nodes
resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.private_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "eks_node_group" {
  name                      = "eks-node-group-autoscaling"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = aws_eks_node_group.private-nodes.subnet_ids
 }





# Create Target Group for EKS Cluster
resource "aws_lb_target_group" "eks_target_group" {
  name        = "eks-target-group"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.private_vpc.id
  target_type = "ip"
  health_check {
    protocol = "HTTPS"
    path     = "/"
    port     = "traffic-port"
  }
}

# Attach EKS Cluster Nodes to Target Group
resource "aws_autoscaling_attachment" "eks_attachment" {
  depends_on             = [aws_lb_target_group.eks_target_group]
  autoscaling_group_name = aws_autoscaling_group.eks_node_group.name
  alb_target_group_arn  = aws_lb_target_group.eks_target_group.arn
}
