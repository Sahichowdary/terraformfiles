resource "aws_vpc" "main" {
  cidr_block = "173.45.0.0/16"

  tags = {
    Name = "main"
  }
}
