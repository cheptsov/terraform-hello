locals {
  stack = "cheptsov_sandbox"
  domain_zone = "sandbox.intellij.net."
  domain_name = "cheptsov.sandbox.intellij.net"
}

module "hello" {
  source = "../../hello"

  prefix = "hello_${local.stack}"
  domain_zone = "${local.domain_zone}"
  domain_name = "${local.domain_name}"
}

data "aws_route53_zone" "public_url_zone" {
  name = "${local.domain_zone}"
}