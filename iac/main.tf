terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

## setup S3 bucket
resource "aws_s3_bucket" "create-contact-bucket"{
    bucket  =   "create-contact-bucket"
    acl     =   "private"
    tags= {
        Name = "create-contact-bucket"
    }    
}

## upload zip file into s3 bucket
resource "aws_s3_bucket_object" "object"{
    bucket =   aws_s3_bucket.create-contact-bucket.id
    key    =    "salesforceContactCreate.zip"
    source =    "${path.module}/salesforceContactCreate.zip"
    etag   =    filemd5("${path.module}/salesforceContactCreate.zip")
}


# setup IAM role for     
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
  Version =  "2012-10-17"
  Statement =  [
    {
      Action =  "sts:AssumeRole"
      Principal =  {
        "Service": "lambda.amazonaws.com"
      }
      Effect: "Allow"
      Sid: ""
    }
  ]
})
}

## lambda function
resource "aws_lambda_function" "saleforce-contact-create" {
  function_name = "contact-create"
  s3_bucket     =   aws_s3_bucket.create-contact-bucket.id
  s3_key        =   "salesforceContactCreate.zip"
  role          =   aws_iam_role.iam_for_lambda.arn
  handler       =   "createContact.handler"
  runtime       =   "nodejs12.x"

  source_code_hash = filebase64sha256("salesforceContactCreate.zip")

    environment {
        variables = {
          "CLIENT_ID"       = "${var.CLIENT_ID}"
          "CLIENT_SECRET"   = "${var.CLIENT_SECRET}"
          "USERNAME"        = "${var.USERNAME}"
          "PASSWORD"        = "${var.PASSWORD}"
          "REDIRECT_URL"    = "${var.REDIRECT_URL}"
          "BUCKET_NAME"     = "${aws_s3_bucket.create-contact-bucket.bucket}"
        }
    }
    
    depends_on = [
      aws_s3_bucket_object.object,
  ]
}

resource "aws_s3_bucket_policy" "create-contact-bucket" {
  bucket = aws_s3_bucket.create-contact-bucket.id
      policy = jsonencode(
      {
      Id = "Policy1630307067283"
      Version = "2012-10-17"
      Statement =  [
        {
          Sid =  "uplodContactLambda"
          Effect =  "Allow"
          Principal =  {
            "AWS" =  [aws_iam_role.iam_for_lambda.arn]
          }
          Action = ["s3:Get*", "s3:List*","s3:Put*"]
          Resource = [
            aws_s3_bucket.create-contact-bucket.arn,
            "${aws_s3_bucket.create-contact-bucket.arn}/*"
          ]
        }
      ]
    })
}