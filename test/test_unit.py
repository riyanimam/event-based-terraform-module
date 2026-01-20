#!/usr/bin/env python3
"""
Unit tests for event-based Terraform module.
"""

import json
import shutil
import subprocess
import unittest
from pathlib import Path

import boto3
from moto import mock_aws


class TestLambdaFunction(unittest.TestCase):
    """Unit tests for Lambda function configuration."""

    @mock_aws
    def setUp(self):
        """Set up test resources."""
        self.lambda_client = boto3.client("lambda", region_name="us-east-1")
        self.iam_client = boto3.client("iam", region_name="us-east-1")

        # Create IAM role for testing
        self.iam_client.create_role(
            RoleName="test-lambda-role",
            AssumeRolePolicyDocument=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "lambda.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                        }
                    ],
                }
            ),
        )

    @mock_aws
    def test_lambda_creation(self):
        """Test Lambda function can be created."""
        lambda_client = boto3.client("lambda", region_name="us-east-1")
        iam_client = boto3.client("iam", region_name="us-east-1")

        # Create IAM role
        iam_client.create_role(
            RoleName="test-role",
            AssumeRolePolicyDocument=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "lambda.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                        }
                    ],
                }
            ),
        )

        # Create Lambda function
        response = lambda_client.create_function(
            FunctionName="test-function",
            Runtime="python3.12",
            Role="arn:aws:iam::123456789012:role/test-role",
            Handler="handler.lambda_handler",
            Code={"ZipFile": b"fake code"},
            Environment={"Variables": {"LOG_LEVEL": "INFO", "ENVIRONMENT": "test"}},
        )

        self.assertEqual(response["FunctionName"], "test-function")
        self.assertEqual(response["Runtime"], "python3.12")
        self.assertIn("LOG_LEVEL", response["Environment"]["Variables"])
        self.assertIn("ENVIRONMENT", response["Environment"]["Variables"])

    @mock_aws
    def test_lambda_configuration(self):
        """Test Lambda configuration parameters."""
        lambda_client = boto3.client("lambda", region_name="us-east-1")
        iam_client = boto3.client("iam", region_name="us-east-1")

        # Create IAM role
        iam_client.create_role(
            RoleName="test-role",
            AssumeRolePolicyDocument=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "lambda.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                        }
                    ],
                }
            ),
        )

        # Create Lambda with specific configuration
        response = lambda_client.create_function(
            FunctionName="test-function",
            Runtime="python3.12",
            Role="arn:aws:iam::123456789012:role/test-role",
            Handler="handler.lambda_handler",
            Code={"ZipFile": b"fake code"},
            Timeout=300,
            MemorySize=128,
        )

        self.assertEqual(response["Timeout"], 300)
        self.assertEqual(response["MemorySize"], 128)


class TestSQSQueue(unittest.TestCase):
    """Unit tests for SQS queue configuration."""

    @mock_aws
    def test_sqs_queue_creation(self):
        """Test SQS queue can be created."""
        sqs_client = boto3.client("sqs", region_name="us-east-1")

        response = sqs_client.create_queue(
            QueueName="test-queue",
            Attributes={
                "VisibilityTimeout": "300",
                "MessageRetentionPeriod": "345600",
                "ReceiveMessageWaitTimeSeconds": "0",
            },
        )

        self.assertIn("QueueUrl", response)
        queue_url = response["QueueUrl"]

        # Verify queue attributes
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url, AttributeNames=["All"]
        )
        self.assertEqual(attrs["Attributes"]["VisibilityTimeout"], "300")
        self.assertEqual(attrs["Attributes"]["MessageRetentionPeriod"], "345600")

    @mock_aws
    def test_sqs_dlq_creation(self):
        """Test DLQ can be created."""
        sqs_client = boto3.client("sqs", region_name="us-east-1")

        response = sqs_client.create_queue(
            QueueName="test-dlq",
            Attributes={"MessageRetentionPeriod": "1209600"},
        )

        self.assertIn("QueueUrl", response)

        # Verify DLQ attributes
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=response["QueueUrl"], AttributeNames=["All"]
        )
        self.assertEqual(attrs["Attributes"]["MessageRetentionPeriod"], "1209600")

    @mock_aws
    def test_sqs_with_redrive_policy(self):
        """Test SQS queue with DLQ redrive policy."""
        sqs_client = boto3.client("sqs", region_name="us-east-1")

        # Create DLQ
        dlq_response = sqs_client.create_queue(QueueName="test-dlq")
        dlq_url = dlq_response["QueueUrl"]
        dlq_attrs = sqs_client.get_queue_attributes(
            QueueUrl=dlq_url, AttributeNames=["QueueArn"]
        )
        dlq_arn = dlq_attrs["Attributes"]["QueueArn"]

        # Create main queue with redrive policy
        redrive_policy = json.dumps(
            {"deadLetterTargetArn": dlq_arn, "maxReceiveCount": 3}
        )

        main_queue = sqs_client.create_queue(
            QueueName="test-queue", Attributes={"RedrivePolicy": redrive_policy}
        )

        # Verify redrive policy
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=main_queue["QueueUrl"], AttributeNames=["All"]
        )
        self.assertIn("RedrivePolicy", attrs["Attributes"])


class TestEventSourceMapping(unittest.TestCase):
    """Unit tests for event source mapping."""

    @mock_aws
    def test_event_source_mapping_creation(self):
        """Test event source mapping can be created."""
        lambda_client = boto3.client("lambda", region_name="us-east-1")
        sqs_client = boto3.client("sqs", region_name="us-east-1")
        iam_client = boto3.client("iam", region_name="us-east-1")

        # Create IAM role
        iam_client.create_role(
            RoleName="test-role",
            AssumeRolePolicyDocument=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"Service": "lambda.amazonaws.com"},
                            "Action": "sts:AssumeRole",
                        }
                    ],
                }
            ),
        )

        # Create Lambda function
        lambda_client.create_function(
            FunctionName="test-function",
            Runtime="python3.12",
            Role="arn:aws:iam::123456789012:role/test-role",
            Handler="handler.lambda_handler",
            Code={"ZipFile": b"fake code"},
        )

        # Create SQS queue
        queue_response = sqs_client.create_queue(QueueName="test-queue")
        queue_attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_response["QueueUrl"], AttributeNames=["QueueArn"]
        )
        queue_arn = queue_attrs["Attributes"]["QueueArn"]

        # Create event source mapping
        mapping = lambda_client.create_event_source_mapping(
            EventSourceArn=queue_arn,
            FunctionName="test-function",
            Enabled=True,
            BatchSize=10,
        )

        self.assertEqual(mapping["EventSourceArn"], queue_arn)
        self.assertEqual(
            mapping["FunctionArn"],
            "arn:aws:lambda:us-east-1:123456789012:function:test-function",
        )
        self.assertEqual(mapping["BatchSize"], 10)
        self.assertEqual(mapping["State"], "Enabled")


class TestCloudWatchLogs(unittest.TestCase):
    """Unit tests for CloudWatch logs configuration."""

    @mock_aws
    def test_log_group_creation(self):
        """Test CloudWatch log group can be created."""
        logs_client = boto3.client("logs", region_name="us-east-1")

        logs_client.create_log_group(logGroupName="/aws/lambda/test-function")

        response = logs_client.describe_log_groups(
            logGroupNamePrefix="/aws/lambda/test-function"
        )

        self.assertEqual(len(response["logGroups"]), 1)
        self.assertEqual(
            response["logGroups"][0]["logGroupName"], "/aws/lambda/test-function"
        )

    @mock_aws
    def test_log_retention(self):
        """Test CloudWatch log retention configuration."""
        logs_client = boto3.client("logs", region_name="us-east-1")

        logs_client.create_log_group(logGroupName="/aws/lambda/test-function")
        logs_client.put_retention_policy(
            logGroupName="/aws/lambda/test-function", retentionInDays=14
        )

        response = logs_client.describe_log_groups(
            logGroupNamePrefix="/aws/lambda/test-function"
        )

        self.assertEqual(response["logGroups"][0]["retentionInDays"], 14)


class TestTerraformConfiguration(unittest.TestCase):
    """Unit tests for Terraform configuration validity."""

    @classmethod
    def setUpClass(cls):
        """Set up test environment."""
        cls.module_dir = Path(__file__).parent.parent / "opentofu"
        cls.terraform_available = shutil.which("terraform") is not None

    @unittest.skipUnless(
        shutil.which("terraform") is not None, "Terraform not available"
    )
    def test_terraform_fmt(self):
        """Test that Terraform files are formatted correctly."""
        result = subprocess.run(
            ["terraform", "fmt", "-check", "-recursive"],
            cwd=self.module_dir,
            capture_output=True,
            text=True,
        )
        self.assertEqual(
            result.returncode,
            0,
            f"Terraform files not formatted correctly:\n{result.stdout}",
        )

    @unittest.skipUnless(
        shutil.which("terraform") is not None, "Terraform not available"
    )
    def test_terraform_validate(self):
        """Test that Terraform configuration is valid."""
        # Initialize first
        subprocess.run(
            ["terraform", "init", "-backend=false"],
            cwd=self.module_dir,
            capture_output=True,
            check=True,
        )

        # Validate
        result = subprocess.run(
            ["terraform", "validate"],
            cwd=self.module_dir,
            capture_output=True,
            text=True,
        )
        self.assertEqual(
            result.returncode, 0, f"Terraform validation failed:\n{result.stderr}"
        )


if __name__ == "__main__":
    unittest.main()
