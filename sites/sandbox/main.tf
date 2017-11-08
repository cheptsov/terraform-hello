locals {
  stack = "cheptsov_sandbox"
}

module "hello" {
  source = "../../hello"

  prefix = "hello_${local.stack}"
}