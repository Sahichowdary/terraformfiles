resource "aws_db_subnet_group" "rds_subnetgroup01" {
  name      = "rds-subnet-main01"
  subnet_ids = [aws_subnet.private-us-east-1a.id, aws_subnet.private-us-east-1b.id]
}

resource "aws_db_instance" "my-pocsql01" {
  allocated_storage    = var.rds.storage
  identifier           = var.rds.name2
  engine               = "mysql"
  engine_version       = var.rds.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds_subnetgroup.name
  instance_class       = "db.t3.micro"
  username             = var.rds.username
  password             = var.rds.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = var.rds.public_access
  snapshot_identifier = "mydemopoc01"
  storage_type = "standard"
  auto_minor_version_upgrade = true
  depends_on = [aws_db_subnet_group.rds_subnetgroup, aws_security_group.db_security_group] 
  vpc_security_group_ids = [aws_security_group.db_security_group.id]  # Attach the security group to the RDS instance
  
}
