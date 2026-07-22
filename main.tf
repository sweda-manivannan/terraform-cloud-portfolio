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