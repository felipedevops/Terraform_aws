resource "aws_ecr_repository" "app_ecr" {
  name                 = "app_name-${var.infra_env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}