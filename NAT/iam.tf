# IAM roles x_x
data "aws_iam_policy_document" "ssmS3" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ds:CreateComputer",
      "ds:DescribeDirectories",
      "ec2:DescribeInstanceStatus",
      "logs:*",
      "ssm:*",
      "ec2messages:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"]
    condition {
      test = "StringLike"
      variable = "iam:AWSServiceName" 
      values = ["ssm.amazonaws.com"]
      }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [ "s3:*",
      "s3-object-lambda:*" ]
    resources = ["*"]
  }
}

# Assume Role Policy 
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create role that will give access to SSM for session manager and S3
resource "aws_iam_role" "zodiarksEC2" {
  name = "zodiarkEC2"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  inline_policy {
    name = "policy-1234"
    policy = data.aws_iam_policy_document.ssmS3.json
  }
}

# Begin IAM policies for Guacamole Bastion
data "aws_iam_policy_document" "guacamoleIAM" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PupLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  statement {
    actions = ["ec2:*"]
    effect = "Allow"
    resources = ["*"]
  }
  
  statement{
    effect = "Allow"
    actions = ["elasticloadbalancing:*"]
    resources = ["*"]
  }

  statement{
    effect = "Allow"
    actions = ["cloudwatch:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["autoscaling:*"]
    resources = ["*"]
  }

  statement{
    effect = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [ "autoscaling.amazonaws.com",
        "ec2scheduled.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com",
        "transitgateway.amazonaws.com"
      ]
    }
  }
}

# Assume Role Policy 
data "aws_iam_policy_document" "guacamole-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "zodiarksGuac" {
  name = "zodiarkGuac"
  assume_role_policy = data.aws_iam_policy_document.guacamole-assume-role-policy.json
  inline_policy {
    name = "guacRole"
    policy = data.aws_iam_policy_document.guacamoleIAM.json
  }
}

resource "aws_iam_instance_profile" "guacProfile" {
  name = "guacProfile"
  role = aws_iam_role.zodiarksGuac.name
}

# Create  an IAM instance profile to associate with the role we created
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.zodiarksEC2.name
}