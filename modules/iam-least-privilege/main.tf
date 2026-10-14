data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = [var.service_principal]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = var.role_name
  description = "IAM role for ${var.role_name} managed by Terraform"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = var.role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Attach AWS SSM Managed Policy to allow keyless, secure terminal access via AWS Systems Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Optional scoped S3 access policy document
data "aws_iam_policy_document" "s3_access" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    sid    = "ListAndReadTargetBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "ReadWriteObjectsInTargetBuckets"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      for arn in var.s3_bucket_arns : "${arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access" {
  count       = length(var.s3_bucket_arns) > 0 ? 1 : 0
  name        = "${var.role_name}-s3-scoped-policy"
  description = "Least-privilege S3 access policy for ${var.role_name}"
  policy      = data.aws_iam_policy_document.s3_access[0].json

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  count      = length(var.s3_bucket_arns) > 0 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_access[0].arn
}

# Instance profile for EC2 consumption
resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
