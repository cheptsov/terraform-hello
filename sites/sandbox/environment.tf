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

provider "aws" {
  region = "us-east-1"
  alias = "us_east_1"
  profile = "jetbrains-sandbox"
}