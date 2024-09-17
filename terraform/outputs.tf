# output "s3_bucket_name" {
#   value = aws_s3_bucket.main.id
# }


output "ec2-dns" {
  value = module.ec2_instance.public_dns
}

output "ecr-url" {
  value = module.ecr.repository_url
}
