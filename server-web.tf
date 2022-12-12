resource "aws_instance" "web-staging" {
  ami                       = "ami-030b8d2037063bab3"
  instance_type             = "t3.micro"
  subnet_id                 = "subnet-0beda27df099c4601"
  vpc_security_group_ids    = [aws_security_group.web-staging-sg.id]
  key_name                  = "ssh-key-web-staging"
  associate_public_ip_address = "true"
  iam_instance_profile      = "EC2-fetch-S3-buckets"

  root_block_device {
    volume_size = 16
  }

  user_data = templatefile("user-data-web.sh", {
    NPM_API_KEY = var.NPM_API_KEY
    GITHUB_OLARM_WEB_PROXY_DEPLOY_KEY = base64gzip(var.GITHUB_OLARM_WEB_PROXY_DEPLOY_KEY)
    GITHUB_OLARM_WEB_LOGIN_DEPLOY_KEY = base64gzip(var.GITHUB_OLARM_WEB_LOGIN_DEPLOY_KEY)
    GITHUB_OLARM_WEB_USERPORTAL_DEPLOY_KEY = base64gzip(var.GITHUB_OLARM_WEB_USERPORTAL_DEPLOY_KEY)
    GITHUB_OLARM_WEB_CC_DEPLOY_KEY = base64gzip(var.GITHUB_OLARM_WEB_CC_DEPLOY_KEY)
  })

  tags = {
    Name = "web-staging"
  }
}
resource "aws_route53_record" "web-staging-private" {
  zone_id = "Z0120810KSHFR6FKXE3J"
  name    = "web-staging"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.web-staging.private_ip]
}
resource "aws_route53_record" "web-staging-public" {
  zone_id = "Z01160843SAN9N22VLXTQ"
  name    = "web-staging"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.web-staging.public_ip]
}

