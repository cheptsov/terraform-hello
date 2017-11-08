
resource "aws_api_gateway_domain_name" "api" {
  domain_name = "${var.domain_name}"
  certificate_arn = "${data.aws_acm_certificate.api.arn}"
}

data "aws_acm_certificate" "api" {
  domain   = "${var.domain_name}"
  statuses = ["ISSUED"]
  provider = "aws.us_east_1"
}

resource "aws_route53_record" "example" {
  zone_id = "${data.aws_route53_zone.domain_zone.id}"

  name = "${aws_api_gateway_domain_name.api.domain_name}"
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.api.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = "${aws_api_gateway_rest_api.hello_api.id}"
  stage_name  = "${aws_api_gateway_deployment.hello_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api.domain_name}"
}

data "aws_route53_zone" "domain_zone" {
  name = "${var.domain_zone}"
}