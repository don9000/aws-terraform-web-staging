terraform {
  cloud {
    organization = "olarm"
    workspaces {
      name = "terraform-aws1"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "af-south-1"
}

resource "aws_key_pair" "ssh-key-web-staging" {
  key_name   = "ssh-key-web-staging"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpiJmiCmiJG3kzpoohgdQl1NuaDQJz8eh40WiBQVkpzyL0N3R9ciq8jC8dvXkCMErqDM4rnM4/oP1HMJLhDlvfa1Ioyb6YBUEKXdW97HepWGNmUAuqCOzfDcKMRnEmew0YSSGO/EIfD+t3QskHoHo0uROeFlLGxwcgps7edm1Evghy7/02TfcdUmDewFJ2J+jpyEwDrcpi0smMm1wtyuD/semW/QRhloo+mzQLuuKtkQ9zAx/asfnO2c06ZGZ0ELVuzBPWLE0lWPrU4dmPQHLfAhZmz3rxf/l8NJwMH1gB0w9GVGgezKGwXmxPT1P7LfhVoK8564PQTcz7Kr2ByTYp olarm-aws"
}

variable "GITHUB_OLARM_APIV4_DEPLOY_KEY" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_APIV4_RUNNER_TOKEN" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_PROXY_DEPLOY_KEY" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_LOGIN_DEPLOY_KEY" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_LOGIN_RUNNER_TOKEN" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_USERPORTAL_DEPLOY_KEY" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_USERPORTAL_RUNNER_TOKEN" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_CC_DEPLOY_KEY" {
  type = string
  default = ""
}

variable "GITHUB_OLARM_WEB_CC_RUNNER_TOKEN" {
  type = string
  default = ""
}

variable "NPM_API_KEY" {
  type = string
  default = ""
}

data "aws_secretsmanager_secret_version" "olarm_config_staging_api_v4" {
  secret_id = "arn:aws:secretsmanager:af-south-1:945519864455:secret:olarm-config-staging-api-v4-J8IUer"
}

data "aws_secretsmanager_secret_version" "olarm-apns-cert" {
  secret_id = "arn:aws:secretsmanager:af-south-1:945519864455:secret:olarm-apns-cert-dv6Xpj"
}

data "aws_secretsmanager_secret_version" "olarm-apns-key-noenc" {
  secret_id = "arn:aws:secretsmanager:af-south-1:945519864455:secret:olarm-apns-key-noenc-WGQEXq"
}

data "aws_secretsmanager_secret_version" "olarm-hms-config" {
  secret_id = "arn:aws:secretsmanager:af-south-1:945519864455:secret:olarm-hms-config-Cqo5lv"
}

data "aws_secretsmanager_secret_version" "olarm-firebase-config" {
  secret_id = "arn:aws:secretsmanager:af-south-1:945519864455:secret:olarm-firebase-config-52vFdL"
}

resource "aws_security_group" "web-staging-sg" {
  name = "web-staging-sg"
  vpc_id = "vpc-0a7379de579213f73"

  tags = {
    Name = "web-staging-sg"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.16.1.0/24"]
    description = "ICMP from VDC"
  }

  ingress {
    from_port   = 22
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["172.16.1.0/24"]
    description = "Any port from VDC"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}