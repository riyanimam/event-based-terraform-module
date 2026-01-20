# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| \< 1.0  | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### 1. Do Not Disclose Publicly

Please do not open a public issue or disclose the vulnerability publicly until we have had a chance to address it.

### 2. Report Privately

Send a detailed report to the project maintainers via:

- GitHub Security Advisories (preferred)
- Email to the project maintainers
- Private message on GitHub

### 3. Include Details

Your report should include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fixes (if any)
- Your contact information

### 4. Response Timeline

- **24 hours**: Initial acknowledgment
- **72 hours**: Preliminary assessment
- **7 days**: Detailed response with timeline
- **30 days**: Security patch release (target)

## Security Best Practices

### Infrastructure as Code

This module follows security best practices:

- **Least Privilege**: IAM roles and policies grant minimal required permissions
- **Encryption**: CloudWatch logs can be encrypted
- **Resource Isolation**: Proper resource naming and tagging
- **Audit Logging**: CloudWatch logging enabled by default

### Automated Security Scanning

This project uses multiple security tools:

- **tfsec**: Terraform static analysis
- **Checkov**: Infrastructure as code scanning
- **Trivy**: Vulnerability and misconfiguration scanning
- **Gitleaks**: Secret detection in commits
- **Dependency Review**: GitHub dependency scanning

### Security Scans in CI/CD

All pull requests are automatically scanned for:

- Terraform security misconfigurations
- Hardcoded secrets and credentials
- Vulnerable dependencies
- Infrastructure vulnerabilities

### AWS Security Considerations

When using this module:

1. **IAM Permissions**: Review and customize IAM policies for your use case
1. **Encryption**: Enable encryption at rest and in transit where needed
1. **Secrets Management**: Use AWS Secrets Manager or Parameter Store
1. **Resource Policies**: Implement resource-based policies appropriately
1. **Monitoring**: Enable CloudWatch alarms and AWS CloudTrail

### Terraform State Security

- Store state in encrypted S3 buckets
- Enable versioning on state buckets
- Use DynamoDB for state locking
- Restrict access to state files
- Never commit state files to version control

### Example Secure Configuration

```hcl
module "secure_lambda" {
  source = "./opentofu"

  function_name    = "secure-processor"
  source_code_path = "lambda.zip"

  # Use environment variables from Secrets Manager
  environment_variables = {
    SECRET_ARN = data.aws_secretsmanager_secret.example.arn
  }

  # Comprehensive tagging
  tags = {
    Environment = "production"
    Compliance  = "required"
    DataClass   = "confidential"
  }
}
```

## Known Security Considerations

### Lambda Execution Role

The default Lambda execution role includes:

- CloudWatch Logs write permissions
- Event source read permissions (SQS, DynamoDB, Kinesis)

**Recommendation**: Extend the IAM policy for application-specific permissions.

### SQS Queue Encryption

By default, SQS queues use SSE (Server-Side Encryption) with AWS managed keys.

**Recommendation**: Use customer-managed KMS keys for sensitive data.

### Dead Letter Queue

Failed messages are sent to a DLQ if configured.

**Recommendation**: Implement DLQ monitoring and alerting.

## Compliance

This module can help meet various compliance requirements:

- **SOC 2**: Audit logging, access controls
- **HIPAA**: Encryption, secure configuration
- **PCI DSS**: Network segmentation, monitoring
- **GDPR**: Data encryption, access controls

**Note**: Compliance is a shared responsibility. Review your specific requirements.

## Security Updates

- Security patches are released as soon as possible
- Subscribe to GitHub releases for notifications
- Review CHANGELOG.md for security-related updates
- Update to the latest version regularly

## Additional Resources

- [AWS Lambda Security Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html)
- [Terraform Security](https://www.terraform.io/docs/cloud/sentinel/index.html)
- [OWASP Serverless Top 10](https://owasp.org/www-project-serverless-top-10/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

## Contact

For security concerns, contact the maintainers via:

- GitHub Security Advisories
- Project issue tracker (for non-sensitive issues)

Thank you for helping keep this project secure!
