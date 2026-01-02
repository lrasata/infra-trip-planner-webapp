variable "bucket_id" {
  type        = string
  description = "The S3 bucket name"
}

variable "bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
}

variable "cloudfront_arn" {
  type        = string
  description = "The ARN of the CloudFront distribution allowed to access the bucket"
}

variable "paths" {
  type        = list(string)
  description = "List of object paths in the bucket the policy applies to"
  default     = ["*"]
}