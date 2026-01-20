## 1.0.0 (2026-01-20)

### Features

* Stand-Up Placeholder Resources, Code, and Structure ([cadc3e9](https://github.com/riyanimam/event-based-terraform-module/commit/cadc3e9951a40dbe56a76cb5963a3e3732bc976b))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project structure with OpenTofu/Terraform modules
- Support for multiple event sources (SQS, DynamoDB, Kinesis, EventBridge)
- SQS queue creation with Dead Letter Queue support
- Lambda function with configurable runtime and memory
- CloudWatch log group with configurable retention
- IAM roles and policies for Lambda execution
- Comprehensive examples (SQS-Lambda)
- Build scripts for Lambda package creation
- Python deployment helper scripts
- Integration test suite
- GitHub Actions workflows:
  - Code quality checks
  - Security scanning (tfsec, Checkov, Trivy)
  - Terraform plan automation
  - Integration testing
  - Automated releases
- Pre-commit hooks configuration
- Documentation (README, CONTRIBUTING, SECURITY)
- EditorConfig for consistent code style
- YAML, Markdown, and Terraform linting

### Changed

- N/A (initial release)

### Deprecated

- N/A

### Removed

- N/A

### Fixed

- N/A

### Security

- Multiple security scanning tools integrated
- Gitleaks for secret detection
- tfsec for Terraform security analysis
- Checkov for infrastructure scanning
- Trivy for vulnerability detection

## [1.0.0] - TBD

### Added

- Initial stable release

[Unreleased]: https://github.com/yourusername/event-based-terraform-module/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/event-based-terraform-module/releases/tag/v1.0.0
