variable "prefix" {
}

variable "domain_zone" {
}

variable "domain_name" {
}

variable "lambda_payload_filename" {
  default = "../../hello/lambda/build/libs/hello-1.0-SNAPSHOT.jar"
}

variable "lambda_function_handler" {
  default = "terraform.hello.HelloLambdaHandler"
}

variable "lambda_runtime" {
  default = "java8"
}