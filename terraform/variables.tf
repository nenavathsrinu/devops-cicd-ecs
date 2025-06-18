variable "aws_region" {
  default = "ap-south-1"
}

variable "app_name" {
  default = "ecs-ci-cd-app"
}

variable "image_url" {
  description = "ECR Image URI with tag"
  type        = string
}