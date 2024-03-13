resource "aws_ecr_repository" "poc_ecr_java" {
  name                 = "food-finder-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
