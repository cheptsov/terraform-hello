terraform {
  backend "s3" {
    bucket = "hello.tfstate"
    key = "terraform.tfstate"
    profile = "sandbox-jetbrains"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "sandbox-jetbrains"
}

provider "aws" {
  region = "us-east-1"
  alias = "us_east_1"
  profile = "sandbox-jetbrains"
}