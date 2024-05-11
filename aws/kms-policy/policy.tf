data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  # Default key policy to restrict AWS access
  default_key_policy = [
    {
      sid    = "Enable root access and prevent permission delegation"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = [local.aws_account_id]
        },
      ]
      actions   = ["kms:*"]
      resources = ["*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:PrincipalType"
          values   = ["Account"]
        },
      ]
    },
    {
      sid    = "Allow access for key administrators"
      effect = "Allow"
      principals = [
        {
          type = "AWS"
          identifiers = [
            "arn:aws:iam::${local.aws_account_id}:role/TERRAFORM",
            "arn:aws:iam::${local.aws_account_id}:role/ADMIN"
          ]
        },
      ]
      actions   = ["kms:*"]
      resources = ["*"]
    },
    {
      sid    = "Enable read access to all identities"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = [local.aws_account_id]
        },
      ]
      actions = [
        "kms:List*",
        "kms:Describe*",
        "kms:Get*",
      ]
      resources = ["*"]
    }
  ]
}

# Merge the default key policy with the new key policy
data "aws_iam_policy_document" "restricted_key_policy" {
  dynamic "statement" {
    for_each = concat(local.default_key_policy, var.key_policy)
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "principals" {
        for_each = try(statement.value.principals, null) == null ? [] : statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, null) == null ? [] : statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}
