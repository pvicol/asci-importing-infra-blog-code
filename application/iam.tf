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

# IAM Policies
# IAM Policy for Management Server
resource "aws_iam_policy" "mgt_main" {
  name        = "mgt_iam_policy"
  policy      = "${data.aws_iam_policy_document.mgt_main.json}"
  description = "The policy used to allow Management Server permissions to troubleshoot services and others."
}

# IAM Policy for Application Servers
resource "aws_iam_policy" "app_main" {
  name        = "app_iam_role"
  policy      = "${data.aws_iam_policy_document.app_main.json}"
  description = "IAM Role used to allow Application Servers to have permissions to access S3."
}

# IAM Policy Attachments
# IAM Policy Attachment for Management Server
resource "aws_iam_role_policy_attachment" "mgt_main" {
  role       = "${aws_iam_role.mgt_main.name}"
  policy_arn = "${aws_iam_policy.mgt_main.arn}"
}

# IAM Policy Attachment for Application Servers
resource "aws_iam_role_policy_attachment" "app_main" {
  role       = "${aws_iam_role.app_main.name}"
  policy_arn = "${aws_iam_policy.app_main.arn}"
}

# IAM Roles
resource "aws_iam_role" "app_main" {
  name               = "app_iam_role"
  description        = "IAM Role used to allow Application Servers to have permissions to access S3."
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
}

resource "aws_iam_role" "mgt_main" {
  name               = "mgt_iam_role"
  description        = "IAM Role used to allow Management Instance have permissions to manage infrastructure and troubleshoot issues."
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
}

# IAM Instance Profiles
resource "aws_iam_instance_profile" "app_main" {
  name = "app_iam_role"
  role = "${aws_iam_role.app_main.name}"
}

resource "aws_iam_instance_profile" "mgt_main" {
  name = "mgt_iam_role"
  role = "${aws_iam_role.mgt_main.name}"
}
