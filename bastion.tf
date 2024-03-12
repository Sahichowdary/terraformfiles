resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.private_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing SSH access from anywhere, you may restrict it as per your requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create bastion host
resource "aws_instance" "bastion_host-POC" {
  instance_type   = "t2.micro" # Set your desired instance type
  ami             = "ami-07d9b9ddc6cd8dd30"
  subnet_id       = aws_subnet.public-us-east-1a.id
  security_groups = [aws_security_group.bastion_sg.name]
  key_name        = "aws-poc-demo"                          # Set your key name for SSH access
}


resource "aws_security_group_rule" "db_from_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.bastion_sg.id
}
