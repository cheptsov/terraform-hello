terraform {
  backend "s3" {
    bucket = "hello.tfstate"
    key = "terraform.tfstate"
    profile = "jetbrains-sandbox"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "jetbrains-sandbox"
}