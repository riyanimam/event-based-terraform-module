#!/usr/bin/env python3
"""
Helper script to deploy Terraform infrastructure with proper validation and checks.
"""

import argparse
import logging
import subprocess
import sys
from pathlib import Path
from typing import Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class TerraformDeployer:
    """Handles Terraform deployment operations."""

    def __init__(self, working_dir: Path, var_file: Optional[Path] = None):
        """
        Initialize the deployer.

        Args:
            working_dir: Directory containing Terraform files
            var_file: Optional path to tfvars file
        """
        self.working_dir = working_dir
        self.var_file = var_file

    def run_command(self, command: list[str]) -> tuple[int, str, str]:
        """
        Run a shell command.

        Args:
            command: Command to run as a list

        Returns:
            Tuple of (return_code, stdout, stderr)
        """
        logger.info(f"Running: {' '.join(command)}")

        result = subprocess.run(
            command, cwd=self.working_dir, capture_output=True, text=True
        )

        return result.returncode, result.stdout, result.stderr

    def init(self) -> bool:
        """
        Initialize Terraform.

        Returns:
            True if successful, False otherwise
        """
        logger.info("Initializing Terraform...")
        returncode, stdout, stderr = self.run_command(["terraform", "init"])

        if returncode != 0:
            logger.error(f"Terraform init failed: {stderr}")
            return False

        logger.info("Terraform initialized successfully")
        return True

    def validate(self) -> bool:
        """
        Validate Terraform configuration.

        Returns:
            True if valid, False otherwise
        """
        logger.info("Validating Terraform configuration...")
        returncode, stdout, stderr = self.run_command(["terraform", "validate"])

        if returncode != 0:
            logger.error(f"Validation failed: {stderr}")
            return False

        logger.info("Validation successful")
        return True

    def format_check(self) -> bool:
        """
        Check Terraform formatting.

        Returns:
            True if properly formatted, False otherwise
        """
        logger.info("Checking Terraform formatting...")
        returncode, stdout, stderr = self.run_command(
            ["terraform", "fmt", "-check", "-recursive"]
        )

        if returncode != 0:
            logger.warning("Formatting issues found. Run 'terraform fmt -recursive'")
            return False

        logger.info("Formatting check passed")
        return True

    def plan(self, out_file: Optional[Path] = None) -> bool:
        """
        Create Terraform plan.

        Args:
            out_file: Optional file to save the plan

        Returns:
            True if plan created successfully, False otherwise
        """
        logger.info("Creating Terraform plan...")

        command = ["terraform", "plan"]
        if self.var_file:
            command.extend(["-var-file", str(self.var_file)])
        if out_file:
            command.extend(["-out", str(out_file)])

        returncode, stdout, stderr = self.run_command(command)

        if returncode != 0:
            logger.error(f"Plan failed: {stderr}")
            return False

        print(stdout)
        logger.info("Plan created successfully")
        return True

    def apply(
        self, plan_file: Optional[Path] = None, auto_approve: bool = False
    ) -> bool:
        """
        Apply Terraform configuration.

        Args:
            plan_file: Optional plan file to apply
            auto_approve: Whether to auto-approve the apply

        Returns:
            True if applied successfully, False otherwise
        """
        logger.info("Applying Terraform configuration...")

        command = ["terraform", "apply"]
        if plan_file:
            command.append(str(plan_file))
        elif auto_approve:
            command.append("-auto-approve")

        if not plan_file and self.var_file:
            command.extend(["-var-file", str(self.var_file)])

        returncode, stdout, stderr = self.run_command(command)

        if returncode != 0:
            logger.error(f"Apply failed: {stderr}")
            return False

        print(stdout)
        logger.info("Apply completed successfully")
        return True

    def destroy(self, auto_approve: bool = False) -> bool:
        """
        Destroy Terraform-managed infrastructure.

        Args:
            auto_approve: Whether to auto-approve the destroy

        Returns:
            True if destroyed successfully, False otherwise
        """
        logger.warning("Destroying Terraform-managed infrastructure...")

        command = ["terraform", "destroy"]
        if auto_approve:
            command.append("-auto-approve")
        if self.var_file:
            command.extend(["-var-file", str(self.var_file)])

        returncode, stdout, stderr = self.run_command(command)

        if returncode != 0:
            logger.error(f"Destroy failed: {stderr}")
            return False

        print(stdout)
        logger.info("Destroy completed successfully")
        return True


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Deploy Terraform infrastructure with validation"
    )
    parser.add_argument(
        "action",
        choices=["init", "validate", "plan", "apply", "destroy"],
        help="Action to perform",
    )
    parser.add_argument(
        "-d",
        "--directory",
        type=Path,
        required=True,
        help="Terraform working directory",
    )
    parser.add_argument("-v", "--var-file", type=Path, help="Path to tfvars file")
    parser.add_argument(
        "--auto-approve", action="store_true", help="Auto-approve apply/destroy"
    )
    parser.add_argument("--plan-file", type=Path, help="Path to plan file")

    args = parser.parse_args()

    # Validate directory exists
    if not args.directory.exists():
        logger.error(f"Directory not found: {args.directory}")
        sys.exit(1)

    # Initialize deployer
    deployer = TerraformDeployer(args.directory, args.var_file)

    # Execute action
    success = False
    if args.action == "init":
        success = deployer.init()
    elif args.action == "validate":
        success = deployer.init() and deployer.validate()
    elif args.action == "plan":
        success = (
            deployer.init() and deployer.validate() and deployer.plan(args.plan_file)
        )
    elif args.action == "apply":
        success = (
            deployer.init()
            and deployer.validate()
            and deployer.apply(args.plan_file, args.auto_approve)
        )
    elif args.action == "destroy":
        success = deployer.destroy(args.auto_approve)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
