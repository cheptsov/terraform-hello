data "archive_file" "zip" {
  output_path = "${path.root}/out/lambda.zip"
  source_dir = "${path.root}/lambda/src"
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
  name = "hello_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.hello_iam.json}"
}

resource "aws_lambda_function" "hello" {
  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  function_name    = "hello"
  role             = "${aws_iam_role.role.arn}"
  handler          = "hello.say_hello"
  runtime          = "python3.6"

  timeout     = "30"
  memory_size = "128"
}