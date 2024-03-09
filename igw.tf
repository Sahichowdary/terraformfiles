resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.private_vpc.id

  tags = {
    Name = "igw"
  }
}
