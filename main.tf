terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.19"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
    region = "us-west-1"
}

locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[- TZ:]/", "")}"
}