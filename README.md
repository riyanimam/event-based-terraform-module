# Event-Based Terraform Module

[![CI](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/ci.yml/badge.svg)](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/ci.yml)
[![Code Quality](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/code-quality.yml/badge.svg)](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/code-quality.yml)
[![Security](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/security.yml/badge.svg)](https://github.com/riyanimam/event-based-terraform-module/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%3E%3D1.0-FFDA18?logo=opentofu)](https://opentofu.org/)
[![AWS](https://img.shields.io/badge/AWS-Lambda%20%7C%20SQS-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A comprehensive Terraform/OpenTofu module for deploying event-driven AWS Lambda functions with support for multiple
event sources including SQS, DynamoDB Streams, Kinesis Streams, and EventBridge.

## Features

- 🚀 **Multiple Event Sources**: Support for SQS, DynamoDB Streams, Kinesis Streams, and EventBridge
- 🔒 **Security First**: Built-in security scanning with tfsec, Checkov, and Trivy
- 📊 **Observability**: CloudWatch Logs integration with configurable retention
- 🔄 **Dead Letter Queue**: Optional DLQ configuration for SQS sources
- 🏷️ **Tagging**: Comprehensive resource tagging support
- **Complete Examples**: Production-ready examples for each event source type

## Architecture

This module creates a complete event-driven architecture with:

- AWS Lambda function with IAM role and policies
- Event source (SQS queue, DynamoDB stream, etc.) or connection to existing source
- Event source mapping
- CloudWatch log group with configurable retention
- Optional Dead Letter Queue (DLQ)

## Requirements

- Terraform/OpenTofu >= 1.0
- AWS Provider ~> 5.0
- AWS account with appropriate permissions

## Usage

### Basic SQS Example

```hcl
module "sqs_lambda" {
  source = "github.com/yourusername/event-based-terraform-module//opentofu"

  function_name      = "my-event-processor"
  lambda_runtime     = "python3.12"
  lambda_handler     = "handler.lambda_handler"
  source_code_path   = "lambda.zip"

  event_source_type   = "sqs"
  create_event_source = true

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Using Existing Event Source

```hcl
module "existing_sqs_lambda" {
  source = "github.com/yourusername/event-based-terraform-module//opentofu"

  function_name      = "my-event-processor"
  lambda_runtime     = "python3.12"
  lambda_handler     = "handler.lambda_handler"
  source_code_path   = "lambda.zip"

  event_source_type   = "sqs"
  create_event_source = false
  event_source_arn    = "arn:aws:sqs:us-east-1:123456789012:my-existing-queue"

  tags = {
    Environment = "production"
  }
}
```

### DynamoDB Stream Example

```hcl
module "dynamodb_lambda" {
  source = "github.com/yourusername/event-based-terraform-module//opentofu"

  function_name      = "dynamodb-stream-processor"
  lambda_runtime     = "python3.12"
  lambda_handler     = "handler.lambda_handler"
  source_code_path   = "lambda.zip"

  event_source_type   = "dynamodb"
  create_event_source = false
  event_source_arn    = "arn:aws:dynamodb:us-east-1:123456789012:table/MyTable/stream/..."

  starting_position = "LATEST"
  batch_size       = 100

  tags = {
    Environment = "production"
  }
}
```

## Module Inputs

| Name                  | Description                         | Type        | Default                    | Required |
| --------------------- | ----------------------------------- | ----------- | -------------------------- | -------- |
| function_name         | Name of the Lambda function         | string      | -                          | yes      |
| lambda_runtime        | Runtime for the Lambda function     | string      | `"python3.12"`             | no       |
| lambda_handler        | Handler for the Lambda function     | string      | `"handler.lambda_handler"` | no       |
| lambda_timeout        | Timeout in seconds                  | number      | `300`                      | no       |
| lambda_memory_size    | Memory size in MB                   | number      | `128`                      | no       |
| source_code_path      | Path to Lambda source code zip      | string      | -                          | yes      |
| event_source_type     | Type of event source                | string      | `"sqs"`                    | no       |
| event_source_arn      | ARN of existing event source        | string      | `null`                     | no       |
| create_event_source   | Whether to create event source      | bool        | `true`                     | no       |
| batch_size            | Batch size for event source mapping | number      | `10`                       | no       |
| starting_position     | Starting position for streams       | string      | `"LATEST"`                 | no       |
| environment_variables | Environment variables for Lambda    | map(string) | `{}`                       | no       |
| log_retention_days    | CloudWatch log retention days       | number      | `14`                       | no       |
| tags                  | Tags to apply to resources          | map(string) | `{}`                       | no       |

See [variables.tf](opentofu/variables.tf) for complete list of inputs.

## Module Outputs

| Name                      | Description                       |
| ------------------------- | --------------------------------- |
| lambda_function_arn       | ARN of the Lambda function        |
| lambda_function_name      | Name of the Lambda function       |
| lambda_role_arn           | ARN of the Lambda execution role  |
| cloudwatch_log_group_name | Name of the CloudWatch log group  |
| sqs_queue_url             | URL of the SQS queue (if created) |
| sqs_dlq_url               | URL of the DLQ (if created)       |

See [outputs.tf](opentofu/outputs.tf) for complete list of outputs.

## Examples

Complete working examples are available in the [examples](opentofu/examples/) directory:

- [SQS Lambda](opentofu/examples/sqs-lambda/) - Lambda triggered by SQS queue

## Development

### Prerequisites

- Terraform/OpenTofu >= 1.0
- Python 3.12+
- AWS CLI configured
- pre-commit (optional but recommended)

### Setup

1. Clone the repository:

```bash
git clone https://github.com/yourusername/event-based-terraform-module.git
cd event-based-terraform-module
```

1. Install pre-commit hooks:

```bash
pre-commit install
```

1. Install Python dependencies:

```bash
pip install -r test/requirements.txt
```

### Testing

Run Terraform validation:

```bash
cd opentofu
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```

Run Python tests:

```bash
pytest test/ -v
```

Run integration tests (requires AWS credentials):

```bash
pytest test/test_integration.py -v
```

### Building Lambda Packages

Use the provided build script:

```bash
./src/build.sh lambda opentofu/examples/sqs-lambda/lambda lambda.zip
```

## CI/CD

This project includes comprehensive GitHub Actions workflows:

- **Code Quality**: Terraform fmt, validate, TFLint, Python linting with Ruff
- **Security**: tfsec, Checkov, Trivy, Gitleaks secret scanning
- **Terraform Plan**: Automatic plan generation on PRs with cost estimation
- **Integration Tests**: Deploy and test infrastructure
- **Release**: Automated versioning with semantic-release

## Security

See [SECURITY.md](SECURITY.md) for security policies and vulnerability reporting.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by AWS best practices for event-driven architectures
- Built with Terraform/OpenTofu best practices in mind
- Security scanning powered by Aqua Security, Bridgecrew, and others

## Support

For issues and questions:

- Open an issue on GitHub
- Check existing issues and discussions
- Review documentation in the [docs](docs/) directory

## Roadmap

- [ ] Add support for EventBridge event patterns
- [ ] Add support for S3 event notifications
- [ ] Add support for SNS event sources
- [ ] Add CloudFormation output format
- [ ] Add Terragrunt examples
- [ ] Add multi-region deployment examples

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
