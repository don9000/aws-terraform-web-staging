resource "aws_instance" "api-staging" {
  ami                       = "ami-030b8d2037063bab3"
  instance_type             = "t3.nano"
  subnet_id                 = "subnet-0beda27df099c4601"
  vpc_security_group_ids    = [aws_security_group.web-staging-sg.id]
  key_name                  = "ssh-key-web-staging"
  associate_public_ip_address = "true"
  iam_instance_profile      = "EC2-fetch-S3-buckets"

  root_block_device {
    volume_size = 16
  }

  user_data = templatefile("user-data-api.sh", {
    OLARM_CONFIG_API = base64gzip(data.aws_secretsmanager_secret_version.olarm_config_staging_api_v4.secret_string)
    NPM_API_KEY = var.NPM_API_KEY
    GITHUB_OLARM_APIV4_DEPLOY_KEY = base64gzip(var.GITHUB_OLARM_APIV4_DEPLOY_KEY)
  })

  tags = {
    Name = "api-staging"
  }
}
resource "aws_route53_record" "api-staging-private" {
  zone_id = "Z0120810KSHFR6FKXE3J"
  name    = "api-staging"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.api-staging.private_ip]
}
resource "aws_route53_record" "api-staging-public" {
  zone_id = "Z01160843SAN9N22VLXTQ"
  name    = "api-staging"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.api-staging.public_ip]
}

