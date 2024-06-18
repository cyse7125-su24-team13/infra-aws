resource "aws_kms_key" "eks_secrets" {
  description = "KMS key for EKS secrets encryption"
}
resource "aws_kms_key" "ebs_encryption" {
  description = "KMS key for EBS volume encryption"
}