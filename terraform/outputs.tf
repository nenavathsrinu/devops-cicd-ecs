output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
