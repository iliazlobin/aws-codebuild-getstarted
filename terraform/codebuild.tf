resource "aws_s3_bucket" "input_bucket" {
  bucket = "codebuild-690612908881-input"
  acl    = "private"
}

# locals {
#   codebuild_zip_name = "codebuild_input.zip"
# }

# data "archive_file" "codebuild_input" {
#   type        = "zip"
#   output_path = "${path.module}/${local.codebuild_zip_name}"
#   source_file = "${path.module}/../codebuild-input/*"
# }

resource "aws_s3_bucket_object" "codebuild" {
  bucket = "${aws_s3_bucket.input_bucket.id}"
  key    = "codebuild_input.zip"
  source = "${"${path.module}/../codebuild-input.zip"}"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "codebuild-690612908881-output"
  acl    = "private"
}

resource "aws_iam_role" "code_build_service_role" {
  name = "CodeBuildServiceRole"

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

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = "${aws_iam_role.code_build_service_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPolicy",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "CodeCommitPolicy",
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3GetObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3PutObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3BucketIdentity",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "codebuild_project"
  service_role  = "${aws_iam_role.code_build_service_role.arn}"

  artifacts {
    type = "S3"
    location = "${aws_s3_bucket.output_bucket.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "S3"
    location        = "${aws_s3_bucket_object.codebuild.bucket}/${aws_s3_bucket_object.codebuild.key}"
  }
}
