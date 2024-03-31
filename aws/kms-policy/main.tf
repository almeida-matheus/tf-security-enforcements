provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "this" {
  description = "Restricted kms key policy example"
  policy = data.aws_iam_policy_document.restricted_key_policy.json
}