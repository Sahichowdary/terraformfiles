resource "aws_vpc" "private_vpc" {
  cidr_block = "173.45.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "private vpc"
  }
}
