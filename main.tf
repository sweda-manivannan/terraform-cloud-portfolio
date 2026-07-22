terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

   provider "aws" {
     region = "eu-west-1"
   }

   resource "aws_s3_bucket" "first_bucket" {
     bucket = "your-name-terraform-demo-2026"
   }

resource "aws_vpc" "lab_platform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lab-platform-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_platform_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-platform-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.lab_platform_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "lab-platform-private-subnet"
  }
}