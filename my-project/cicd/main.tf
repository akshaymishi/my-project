provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "my-codepipeline-bucket"
}

resource "aws_codepipeline" "my_pipeline" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "akshaymishi"
        Repo       = "my-project"
        Branch     = "main"
        OAuthToken = "your-github-oauth-token"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.my_build_project.name
      }
    }
  }

  stage {
    name = "DeployFrontend"

    action {
      name             = "DeployFrontend"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy_frontend_project.name
      }
    }
  }

  stage {
    name = "DeployBackend"

    action {
      name             = "DeployBackend"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy_backend_project.name
      }
    }
  }
}

resource "aws_codebuild_project" "my_build_project" {
  name          = "my-build-project"
  service_role  = aws_iam_role.codepipeline_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

phases:
  install:
    commands:
      - apt-get update && apt-get install -y unzip
      - curl -o terraform.zip https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
      - unzip terraform.zip
      - mv terraform /usr/local/bin/
  build:
    commands:
      - terraform init
      - terraform apply -auto-approve
EOF
  }
}

resource "aws_codebuild_project" "deploy_frontend_project" {
  name          = "deploy-frontend-project"
  service_role  = aws_iam_role.codepipeline_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

phases:
  build:
    commands:
      - terraform init
      - terraform apply -auto-approve -target=aws_autoscaling_group.new_frontend_asg
      - terraform destroy -auto-approve -target=aws_autoscaling_group.old_frontend_asg
EOF
  }
}

resource "aws_codebuild_project" "deploy_backend_project" {
  name          = "deploy-backend-project"
  service_role  = aws_iam_role.codepipeline_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

phases:
  build:
    commands:
      - terraform init
      - terraform destroy -auto-approve -target=aws_autoscaling_group.old_backend_asg
      - terraform apply -auto-approve -target=aws_autoscaling_group.new_backend_asg
EOF
  }
}