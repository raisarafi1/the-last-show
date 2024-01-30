terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}


# creating bucket
# S3 bucket
# if you omit the name, Terraform will assign a random name to it
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "lambda" {}

# output the name of the bucket after creation
output "bucket_name" {
  value = aws_s3_bucket.lambda.bucket
}

# the locals block is used to declare constants that 
# you can use throughout your code
locals {
  function_name = "create-obituary-30148383"
  handler_name  = "main.handler"
  artifact_name = "${local.function_name}/deployment.zip"
}

# create a role for the Lambda function to assume
# every service on AWS that wants to call other AWS services should first assume a role.
# then any policy attached to the role will give permissions
# to the service so it can interact with other AWS services
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "lambda" {
  name               = "iam-for-lambda-${local.function_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "zip_the_python_code" {
  type = "zip"
  # source_dir     = "${path.module}/functions/create-obituary/"
  # output_path = "${path.module}/functions/create-obituary/main.zip"
  output_path = "C:/Users/rafir/Documents/Raisa/University/Year 2/W2023/ENSF 381/the-last-show-raisa-and-rida/functions/create-obituary/package.zip"
  source_dir  = "C:/Users/rafir/Documents/Raisa/University/Year 2/W2023/ENSF 381/the-last-show-raisa-and-rida/functions/create-obituary"
}

# create a Lambda function
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "lambda" {
  # filename      = "${path.module}/functions/create-obituary/main.zip"
  s3_bucket     = aws_s3_bucket.lambda.bucket
  s3_key        = local.artifact_name
  role          = aws_iam_role.lambda.arn
  function_name = local.function_name
  handler       = local.handler_name
  # change if there are errors
  timeout = 20
  # source_code_hash = "${filebase64sha256(local.artifact_name)}"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}

# create a policy for publishing logs to CloudWatch
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "logs" {
  name        = "lambda-logging-${local.function_name}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# attach the above policy to the function role
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.logs.arn
}

#need ssm permissions
resource "aws_iam_policy" "ssm_policy" {
  name = "ssm_policy-OAI"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:ca-central-1:673442777471:parameter/chatgpt-api-key"
        Resource = "arn:aws:ssm:ca-central-1:673442777471:parameter/cloudinary_api_key"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  policy_arn = aws_iam_policy.ssm_policy.arn
  role       = aws_iam_role.lambda.name
}

# resource "aws_iam_policy" "ssm_policy" {
#   name = "ssm_policy-OAI"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "ssm:GetParameter"
#         Resource = "arn:aws:ssm:ca-central-1:673442777471:parameter/chatgpt-api-key"
#       }
#     ]
#   })
# }


# -----------------------------------------------------------------------------------------------------------------------------
# creating dynamo table
resource "aws_dynamodb_table" "the-last-show-30140980" {
  name         = "the-last-show-30140980"
  billing_mode = "PROVISIONED"

  # up to 8KB read per second (eventually consistent)
  read_capacity = 1

  # up to 1KB per second
  write_capacity = 1

  hash_key = "name" #primary key

  attribute {
    name = "name"
    type = "S"
  }

}


# create a Function URL for Lambda
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url
resource "aws_lambda_function_url" "url" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}
# show the Function URL after creation
output "lambda_url" {
  value = aws_lambda_function_url.url.function_url
}