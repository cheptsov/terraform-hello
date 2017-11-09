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

resource "aws_iam_role" "hello_role" {
  name = "${var.prefix}_hello_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.hello_iam.json}"
}

resource "null_resource" "hello_fat_jar" {
  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "gradle fatJar --project-dir ../../hello/lambda/"
  }
}

resource "aws_lambda_function" "hello_lamda_function" {
  depends_on = ["null_resource.hello_fat_jar"]

  filename         = "${var.lambda_payload_filename}"
  source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"

  function_name    = "${var.prefix}_hello"
  role             = "${aws_iam_role.hello_role.arn}"
  handler          = "${var.lambda_function_handler}"
  runtime          = "${var.lambda_runtime}"

  timeout     = "30"
  memory_size = "128"
}

resource "aws_api_gateway_rest_api" "hello_rest_api" {
  name        = "${var.prefix}_api"
}

resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_rest_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.hello_rest_api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_method_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_rest_api.id}"
  resource_id   = "${aws_api_gateway_resource.hello_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_rest_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_resource.id}"
  http_method = "${aws_api_gateway_method.hello_method_get.http_method}"
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_lamda_function.arn}/invocations"
}

resource "aws_api_gateway_deployment" "hello_deployment" {
  depends_on = [
    "aws_lambda_function.hello_lamda_function",
    "aws_api_gateway_method.hello_method_get",
    "aws_api_gateway_integration.hello_integration",
    "aws_lambda_permission.hello_method_get"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.hello_rest_api.id}"
  stage_name = "${var.prefix}_api"
}

resource "aws_lambda_permission" "hello_method_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello_lamda_function.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.hello_rest_api.id}/*/${aws_api_gateway_method.hello_method_get.http_method}/${aws_api_gateway_resource.hello_resource.path_part}"
}


data "aws_region" "current" {
  current = true
}

data "aws_caller_identity" "current" {
}