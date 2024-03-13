resource "aws_security_group" "bastion_sg-poc" {
  name        = "bastion-security-group-poc"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.private_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing SSH access from anywhere, you may restrict it as per your requirements
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
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


resource "aws_instance" "bastion_host-POC" {
  instance_type   = "t2.micro"                                 # Set your desired instance type
  ami             = "ami-07d9b9ddc6cd8dd30"
  subnet_id       = aws_subnet.public-us-east-1a.id
  security_groups = [aws_security_group.bastion_sg-poc.id]        # Corrected reference to security group name
  key_name        = "aws-poc-demo"                              # Set your key name for SSH access 
  depends_on = [aws_db_instance.my-pocsql, aws_security_group.bastion_sg-poc]
  user_data       =  <<EOF
    #!/bin/bash
    apt sudo apt install mysql-server -y
    mysql -h ${aws_db_instance.my-pocsql.endpoint} -u ${var.rds.username} -p${var.rds.password} 
    CREATE DATABASE IF NOT EXISTS foodfinder;
    USE foodfinder;
    CREATE TABLE IF NOT EXISTS users (first_name VARCHAR(255), last_name VARCHAR(255), username VARCHAR(255), email VARCHAR(255), password VARCHAR(255)); 
    INSERT INTO users (first_name, last_name, username, email, password) VALUES ('raj', 'kapoor', 'rajKapoor', 'raj.kapoor@gmail.com', 'rajKapoor');
  EOF
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "Bastion by Terraform"
  }
}




resource "aws_security_group_rule" "db_from_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.db_security_group.id
}

