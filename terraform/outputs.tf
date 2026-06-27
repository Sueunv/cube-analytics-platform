output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "region" {
  value = var.aws_region
}

output "public_ip" {

  value = aws_instance.cube.public_ip

}

output "public_dns" {

  value = aws_instance.cube.public_dns

}

output "ecr_url" {

  value = aws_ecr_repository.cube.repository_url

}