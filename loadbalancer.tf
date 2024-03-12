
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

