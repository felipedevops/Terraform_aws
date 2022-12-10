resource "aws_codepipeline" "codepipeline" {
  name     = "tf-${var.infra_env}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "source_App"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      run_order        = 1
      output_artifacts = ["source_App"]
      configuration = {
        Repo       = "${var.git_repo_app}"
        Branch     = "${var.branchname}"
        OAuthToken = "${var.github_oauth_token}"
        Owner      = "${var.repo_owner}"
      }
    }
    action {
      name             = "Devops"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      run_order        = 2
      output_artifacts = ["source_Devops"]
      configuration = {
        Repo       = "${var.git_repo}"
        Branch     = "${var.infra_env}"
        OAuthToken = "${var.github_oauth_token}"
        Owner      = "${var.repo_owner}"
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
      input_artifacts  = ["source_App", "source_Devops"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName   = "${aws_codebuild_project.codebuild_project_terraform_plan.name}"
        PrimarySource = "source_Devops"
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