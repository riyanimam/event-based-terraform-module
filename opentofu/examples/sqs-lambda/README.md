# SQS-Lambda Example

This example demonstrates how to use the event-based-terraform-module to create a Lambda function triggered by an SQS
queue.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform/OpenTofu >= 1.0
- A Lambda deployment package (lambda.zip)

## Usage

1. Create a Lambda deployment package:

```bash
cd lambda
zip -r ../lambda.zip .
cd ..
```

1. Initialize Terraform:

```bash
terraform init
```

1. Review the plan:

```bash
terraform plan
```

1. Apply the configuration:

```bash
terraform apply
```

## What Gets Created

- Lambda function
- IAM role and policies for Lambda execution
- CloudWatch log group
- SQS queue
- SQS Dead Letter Queue (DLQ)
- Event source mapping between SQS and Lambda

## Testing

Send a message to the SQS queue:

```bash
aws sqs send-message \
  --queue-url $(terraform output -raw sqs_queue_url) \
  --message-body '{"test": "message"}'
```

Check the Lambda logs:

```bash
aws logs tail /aws/lambda/sqs-event-processor --follow
```

## Clean Up

```bash
terraform destroy
```
