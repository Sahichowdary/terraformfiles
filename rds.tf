resource "aws_db_instance" "my-pocsql" {
  allocated_storage    = var.rds.storage
  db_name              = "mysqlpoc_sasken"
  identifier           = var.rds.name
  engine               = "mysql"
  engine_version       = var.rds.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds_subnetgroup.name
  instance_class       = "db.t3.micro"
  username             = var.rds.username
  password             = var.rds.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = var.rds.public_access
  storage_type = "standard"
  depends_on = [aws_db_subnet_group.rds_subnetgroup] 

  provisioner "local-exec" {
    command = <<-EOT
      mysql -h ${self.endpoint} -u ${var.rds.username} -p${var.rds.password} \
      -e "CREATE DATABASE IF NOT EXISTS foodfinder; \
      USE foodfinder; \
      CREATE TABLE IF NOT EXISTS users (first_name VARCHAR(255), last_name VARCHAR(255), username VARCHAR(255), email VARCHAR(255), password VARCHAR(255)); \
      INSERT INTO users (first_name, last_name, username, email, password) VALUES ('raj', 'kapoor', 'rajKapoor', 'raj.kapoor@gmail.com', 'rajKapoor');"
    EOT
  }
}
