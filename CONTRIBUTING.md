# Contributing to Event-Based Terraform Module

Thank you for considering contributing to this project! We welcome contributions from the community.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Environment details (Terraform version, AWS region, etc.)
- Any relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the proposed functionality
- Explain why this enhancement would be useful
- Include code examples if applicable

### Pull Requests

1. Fork the repository

1. Create a feature branch (`git checkout -b feature/amazing-feature`)

1. Make your changes

1. Run tests and validation:

   ```bash
   terraform fmt -recursive opentofu/
   terraform validate
   pytest test/
   ```

1. Commit your changes using conventional commits:

   ```bash
   git commit -m "feat: add amazing feature"
   ```

1. Push to your branch (`git push origin feature/amazing-feature`)

1. Open a Pull Request

## Development Setup

### Prerequisites

- Terraform/OpenTofu >= 1.0
- Python 3.12+
- AWS CLI configured
- Git
- pre-commit (recommended)

### Local Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/event-based-terraform-module.git
cd event-based-terraform-module

# Install pre-commit hooks
pre-commit install

# Install Python dependencies
pip install -r test/requirements.txt
```

### Running Tests

```bash
# Terraform validation
cd opentofu
terraform init -backend=false
terraform validate
terraform fmt -check -recursive

# Python tests
pytest test/ -v --cov

# Integration tests (requires AWS)
pytest test/test_integration.py -v
```

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:

```text
feat: add support for EventBridge event sources
fix: correct IAM policy for DynamoDB streams
docs: update README with usage examples
```

## Code Style

### Terraform

- Use 2-space indentation
- Follow Terraform naming conventions (snake_case)
- Document all variables and outputs
- Use meaningful resource names
- Group related resources in separate files

### Python

- Follow PEP 8 style guide
- Use Ruff for linting and formatting
- Write docstrings for all functions and classes
- Use type hints where applicable
- Keep functions focused and testable

## Documentation

- Update README.md for user-facing changes
- Update examples for new features
- Add inline comments for complex logic
- Update CHANGELOG.md (semantic-release handles this automatically)

## Testing Requirements

All contributions should include appropriate tests:

- **Terraform**: Validate and format checks
- **Python**: Unit tests with pytest
- **Integration**: End-to-end tests for new features

## Review Process

1. Automated checks must pass (CI/CD workflows)
1. Code review by maintainers
1. Documentation reviewed
1. Tests verified
1. Approval and merge

## Release Process

This project uses semantic-release for automated versioning and releases:

1. Commits are analyzed for version bumps
1. CHANGELOG is automatically generated
1. GitHub release is created
1. Tags are applied automatically

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review closed issues and PRs
- Reach out to maintainers

## Recognition

Contributors will be recognized in:

- GitHub contributors list
- Release notes
- Project documentation

Thank you for contributing! 🎉
