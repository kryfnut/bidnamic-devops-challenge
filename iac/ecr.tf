#Defining the AWS ECR - container registry for images in bidnamic cluster

resource "aws_ecr_repository" "bidnamic_ecr" {
  name                 = "bidnamic-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}