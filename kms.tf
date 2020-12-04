resource "aws_kms_key" "pca-kms" {
  description         = "KMS Key for encrypting the PCA s3 bucket"
  enable_key_rotation = "true"
  policy              = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-policy-with-replication",
    "Statement": [
          {
            "Sid": "Account usage of KMS Key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
      ]
}
EOF
}

resource "aws_kms_alias" "pca-kims-alias" {
  name          = "alias/pca-kims-alias"
  target_key_id = aws_kms_key.pca-kms.key_id
}
