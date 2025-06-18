provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecr_repository" "app_repo" {
  name = "ecs-app-repo"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-ci-cd-cluster"
}

# Add VPC, Subnets, IAM, Security Groups, Task definition and ECS service here
# I can provide the full Terraform config if needed

output "ecr_url" {
  value = aws_ecr_repository.app_repo.repository_url
}