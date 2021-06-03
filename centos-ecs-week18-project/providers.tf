terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

provider "aws" {
  region = "us-east-1"
}

