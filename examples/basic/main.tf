provider "aws" {
  region = "us-east-1"
}

module "event_processor" {
  source = "../../modules/event-processor"

  environment         = "dev"
  project            = "example"
  lambda_function_name = "example-processor"
  lambda_handler      = "index.handler"
  lambda_runtime      = "nodejs18.x"
  lambda_source_path  = "./src"
  sqs_queue_name     = "example-queue"

  tags = {
    Owner = "DevOps"
  }
}
