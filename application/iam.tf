# IAM
# IAM Policy Documents
# EC2 trust relationship creation for IAM Role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Policy Document for Application Servers
data "aws_iam_policy_document" "app_main" {
  statement {
    sid = "AllowS3Access"

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:RestoreObject",
    ]

    resources = [
      "*",
    ]
  }
}

# IAM Policy Document for Management Server
data "aws_iam_policy_document" "mgt_main" {
  statement {
    sid = "AllowEC2Management"

    actions = [
      "ec2:RebootInstances",
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:StartInstances",
      "ec2:RunInstances",
      "ec2:StopInstances",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowS3Management"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetBucketPolicy",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutBucketPolicy",
      "s3:PutObject",
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags",
      "s3:RestoreObject",
    ]

    resources = [
      "*",
    ]
  }
}

# IAM Role and Policy for management server
module "mgmt_role" {
  source             = "../modules/iam/"
  policy_name        = "mgt_iam_policy"
  policy_json        = "${data.aws_iam_policy_document.mgt_main.json}"
  policy_description = "The policy used to allow Management Server permissions to troubleshoot services and others."

  role_name         = "mgt_iam_role"
  role_trust_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
  role_description  = "IAM Role used to allow Management Instance have permissions to manage infrastructure and troubleshoot issues."
}

# IAM Role and Policy for app servers
module "app_role" {
  source             = "../modules/iam/"
  policy_name        = "app_iam_policy"
  policy_json        = "${data.aws_iam_policy_document.app_main.json}"
  policy_description = "IAM policy used to allow Application Servers to have permissions to access S3."

  role_name         = "app_iam_role"
  role_trust_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
  role_description  = "IAM Role used to allow Application Servers to have permissions to access S3."
}
