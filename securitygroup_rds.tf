# Create a security group for the RDS instance
resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for the RDS instance"
  vpc_id      = aws_vpc.private_vpc.id  # Replace my_vpc with your VPC ID

  // Add any additional inbound/outbound rules here if needed
}

# Define inbound rule for MySQL port (3306)
resource "aws_security_group_rule" "mysql_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow access from anywhere (adjust as needed)
  security_group_id = aws_security_group.db_security_group.id
}

resource "aws_security_group_rule" "mysql_inbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow access from anywhere (adjust as needed)
  security_group_id = aws_security_group.db_security_group.id
}
