# IAM
resource "aws_iam_role" "codebuild_role" {
  count = var.create_role_and_policy ? 1 : 0
  name  = "${var.infra_env}_codebuild_deploy_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy" {
  role       = aws_iam_role.codebuild_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "codebuild_project_terraform_plan" {
  name          = "${var.infra_env}_devops_codebuild"
  description   = "Terraform codebuild project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role[0].arn #var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  #cache {
  #  type     = "S3"
  #  location = var.s3_logging_bucket
  #}

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.16"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    #s3_logs {
    #  status   = "ENABLED"
    #  location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_plan_name}/build-log"
    #}
  }

  source {
    type            = "GITHUB"
    location        = "${var.git_repo}"
    git_clone_depth = var.git_clone_depth
    buildspec       = templatefile("${path.cwd}/${var.build_spec_file}", {})
    git_submodules_config {
      fetch_submodules = true
    }

#  source {
#    type      = "CODEPIPELINE"
#    buildspec = "buildspec_terraform_plan.yml"
#}

  tags = {
    Terraform = "true"
  }
}