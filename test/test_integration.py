#!/usr/bin/env python3
"""
Integration tests for event-based Terraform module.
"""

import json
import os
import subprocess
import time
import unittest
from pathlib import Path
from typing import Optional

import boto3


class TestEventBasedLambda(unittest.TestCase):
    """Integration tests for event-based Lambda infrastructure."""

    @classmethod
    def setUpClass(cls):
        """Set up test resources."""
        cls.terraform_dir = (
            Path(__file__).parent.parent / "opentofu" / "examples" / "sqs-lambda"
        )
        cls.aws_region = os.getenv("AWS_REGION", "us-east-1")

        # Initialize AWS clients
        cls.lambda_client = boto3.client("lambda", region_name=cls.aws_region)
        cls.sqs_client = boto3.client("sqs", region_name=cls.aws_region)
        cls.logs_client = boto3.client("logs", region_name=cls.aws_region)

        # Get outputs from Terraform
        cls.function_name = cls._get_terraform_output("lambda_function_name")
        cls.queue_url = cls._get_terraform_output("sqs_queue_url")

    @classmethod
    def _get_terraform_output(cls, output_name: str) -> Optional[str]:
        """
        Get Terraform output value.

        Args:
            output_name: Name of the output

        Returns:
            Output value or None
        """
        try:
            result = subprocess.run(
                ["terraform", "output", "-raw", output_name],
                cwd=cls.terraform_dir,
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return None

    def test_lambda_function_exists(self):
        """Test that Lambda function exists."""
        response = self.lambda_client.get_function(FunctionName=self.function_name)
        self.assertIsNotNone(response["Configuration"])
        self.assertEqual(response["Configuration"]["Runtime"], "python3.12")

    def test_sqs_queue_exists(self):
        """Test that SQS queue exists."""
        response = self.sqs_client.get_queue_attributes(
            QueueUrl=self.queue_url, AttributeNames=["All"]
        )
        self.assertIsNotNone(response["Attributes"])

    def test_event_source_mapping_exists(self):
        """Test that event source mapping exists."""
        response = self.lambda_client.list_event_source_mappings(
            FunctionName=self.function_name
        )
        self.assertGreater(len(response["EventSourceMappings"]), 0)
        self.assertEqual(response["EventSourceMappings"][0]["State"], "Enabled")

    def test_message_processing(self):
        """Test that messages are processed by Lambda."""
        # Send test message
        test_message = {"test": "message", "timestamp": time.time()}
        self.sqs_client.send_message(
            QueueUrl=self.queue_url, MessageBody=json.dumps(test_message)
        )

        # Wait for processing
        time.sleep(10)

        # Check CloudWatch logs
        log_group_name = f"/aws/lambda/{self.function_name}"
        try:
            response = self.logs_client.filter_log_events(
                logGroupName=log_group_name,
                limit=50,
                startTime=int((time.time() - 60) * 1000),
            )
            log_messages = [event["message"] for event in response["events"]]
            self.assertTrue(
                any("Processing message" in msg for msg in log_messages),
                "Lambda did not process the message",
            )
        except Exception as e:
            self.fail(f"Failed to check logs: {e}")

    def test_dlq_exists(self):
        """Test that Dead Letter Queue exists."""
        dlq_url = self._get_terraform_output("sqs_dlq_url")
        if dlq_url:
            response = self.sqs_client.get_queue_attributes(
                QueueUrl=dlq_url, AttributeNames=["All"]
            )
            self.assertIsNotNone(response["Attributes"])

    def test_lambda_environment_variables(self):
        """Test that Lambda has correct environment variables."""
        response = self.lambda_client.get_function(FunctionName=self.function_name)
        env_vars = response["Configuration"].get("Environment", {}).get("Variables", {})
        self.assertIn("LOG_LEVEL", env_vars)
        self.assertIn("ENVIRONMENT", env_vars)


class TestTerraformConfiguration(unittest.TestCase):
    """Tests for Terraform configuration validity."""

    @classmethod
    def setUpClass(cls):
        """Set up test environment."""
        cls.module_dir = Path(__file__).parent.parent / "opentofu"

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
