resource "aws_vpc" "private_vpc" {
  cidr_block = "173.45.0.0/16"

  tags = {
    Name = "private vpc"
  }
}
