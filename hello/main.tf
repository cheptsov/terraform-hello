data "archive_file" "zip" {
  output_path = "${path.root}/../../out/lambda.zip"
  source_dir = "${path.root}/../../lambda/src"
  type = "zip"
}

data "aws_iam_policy_document" "hello_iam" {
  statement {
    actions = [ "sts:AssumeRole"]
    principals {
      identifiers = [ "lambda.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name = "${var.prefix}_hello_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.hello_iam.json}"
}

resource "aws_lambda_function" "hello" {
  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  function_name    = "${var.prefix}_hello"
  role             = "${aws_iam_role.role.arn}"
  handler          = "hello.say_hello"
  runtime          = "python3.6"

  timeout     = "30"
  memory_size = "128"
}

resource "aws_api_gateway_rest_api" "hello_api" {
  name        = "${var.prefix}_api"
}

resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.hello_api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_method_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_api.id}"
  resource_id   = "${aws_api_gateway_resource.hello_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_resource.id}"
  http_method = "${aws_api_gateway_method.hello_method_get.http_method}"
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello.arn}/invocations"
}

resource "aws_api_gateway_deployment" "hello_deployment" {
  depends_on = [
    "aws_lambda_function.hello",
    "aws_api_gateway_method.hello_method_get",
    "aws_api_gateway_integration.hello_integration",
    "aws_lambda_permission.hello_method_get"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
  stage_name = "${var.prefix}_api"
}

resource "aws_lambda_permission" "hello_method_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.hello_api.id}/*/${aws_api_gateway_method.hello_method_get.http_method}/${aws_api_gateway_resource.hello_resource.path_part}"
}


data "aws_region" "current" {
  current = true
}

data "aws_caller_identity" "current" {
}