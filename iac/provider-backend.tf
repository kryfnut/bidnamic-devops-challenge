#Defining the required providers -  Hashicorp AWS and Kubernetes. 
#Also setting the Terraform backend to S3 bucket and dedicated folder with file encryption enabled.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.3.1"
    }
  }

  backend "s3" {
    bucket  = "iac-tobi-solomon"
    key     = "bidnamic/"
    region  = "eu-west-2"
    profile = "tobi"
    encrypt = true
  }
}

#Defining the path to local AWS configuration file for remote connection to my personal AWS environment.

provider "aws" {
  region                  = "eu-west-2"
  shared_credentials_file = "/Users/mcsmallz/.aws/credentials"
  profile                 = "tobi"
}