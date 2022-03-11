# S3 Practice
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}


provider "aws" {
  region = "us-west-2"
}

# Create a bucket
resource "aws_s3_bucket" "bucket1" {
    bucket = "seans-bucket-of-runes"

    tags = {
        Name = "Runes"
        Environment = "Dev"
    }
}

# Create encryption key for bucket objects
resource "aws_kms_key" "examplekms" {
    description = "KMS key 1"
    deletion_window_in_days = 7
}

# Ensure bucket is private? Should default to private.
resource "aws_s3_bucket_acl" "nolooking" {
    bucket = "seans-bucket-of-runes"
    acl = "private"
}

# Upload photo (object) to the bucket
resource "aws_s3_object" "myPlants" {
    bucket = aws_s3_bucket.bucket1.id 
    key = "myPlants"
    source = "/home/sean/Pictures/Green-Tropical-Plant-Wallpaper-Mural-Plain-820x532.jpg"
    kms_key_id = aws_kms_key.examplekms.arn
}

# Enable Version Control
resource "aws_s3_bucket_versioning" "versionControl" {
    bucket = aws_s3_bucket.bucket1.id
    versioning_configuration {
        status = "Enabled"
    }
}

# Move files over to standard IA after 31 days
resource "aws_s3_bucket_lifecycle_configuration" "example" {
    bucket = aws_s3_bucket.bucket1.id
    
    rule {
        id = "rule-1"
        status = "Enabled"
        transition {
            days = 31
            storage_class = "STANDARD_IA"
        }
    }
}

# This data source can be used to fetch information about a specific
# IAM user.
data "aws_iam_user" "anyuser" {
    user_name = "anyuser"
}

# Create a policy that prevents "anyuser" from listing the bucket.
data "aws_iam_policy_document" "deny_listing" {
    statement {
        principals {
            type = "AWS"
            identifiers = [
                "${data.aws_iam_user.anyuser.arn}"
            ]
        }

        actions = [ 
            "s3:ListBucket" 
        ]

        effect = "Deny"
    
        resources = [ 
            aws_s3_bucket.bucket1.arn,
            "${aws_s3_bucket.bucket1.arn}/*"
        ]
    }
}

# Apply a policy to a bucket resource
resource "aws_s3_bucket_policy" "deny_listing" {
    bucket = aws_s3_bucket.bucket1.id
    policy = data.aws_iam_policy_document.deny_listing.json
}

