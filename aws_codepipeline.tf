resource "aws_codepipeline" "codepipeline" {
  name     = "tf-${var.infra_env}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    #encryption_key {
    #  id   = data.aws_kms_alias.s3kmskey.arn
    #  type = "KMS"
    #}
  }

  stage {
    name = "${var.infra_env}-Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.example.arn
        FullRepositoryId = "my-organization/example"
        BranchName       = "${var.branchname}"
      }
    }
  }

  stage {
    name = "${var.infra_env}-Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      #buildspec = <<BUILDSPEC
      #version: 0.2
      #
      #phases:
      #  build:
      #    commands:
      #       - echo "testing"
      #BUILDSPEC

      configuration = {
        ProjectName = "${var.infra_env}-Project"
      }
    }
  }

  stage {
    name = "${var.infra_env}-Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "${var.infra_env}-CreateStackOutput.json"
        StackName      = "${var.infra_env}-Stack"
        TemplatePath   = "build_output::sam-templated.yaml"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "example" {
  name          = "${var.infra_env}-connection"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.infra_env}-bucket-20221201142622"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

#data "aws_kms_alias" "s3kmskey" {
#  name = "alias/myKmsKey"
#}