#!/usr/bin/env bash
# Build script for Lambda deployment packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build Python Lambda package
build_python_lambda() {
  local src_dir="$1"
  local output_zip="$2"

  log_info "Building Python Lambda package from ${src_dir}"

  # Create temp directory
  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf ${temp_dir}" EXIT

  # Copy source files
  cp -r "${src_dir}"/* "${temp_dir}/"

  # Install dependencies if requirements.txt exists
  if [ -f "${src_dir}/requirements.txt" ]; then
    log_info "Installing dependencies..."
    pip install -r "${src_dir}/requirements.txt" -t "${temp_dir}" --quiet
  fi

  # Create zip file
  log_info "Creating deployment package: ${output_zip}"
  cd "${temp_dir}"
  zip -r "${output_zip}" . -q

  log_info "Build complete: ${output_zip}"
}

# Function to validate Terraform files
validate_terraform() {
  local terraform_dir="$1"

  log_info "Validating Terraform files in ${terraform_dir}"

  cd "${terraform_dir}"

  if ! command -v terraform &> /dev/null; then
    log_error "Terraform not found. Please install Terraform."
    return 1
  fi

  terraform init -backend=false
  terraform validate

  log_info "Terraform validation complete"
}

# Main execution
main() {
  case "${1:-}" in
    lambda)
      if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
        log_error "Usage: $0 lambda <source_dir> <output_zip>"
        exit 1
      fi
      build_python_lambda "$2" "$3"
      ;;
    validate)
      if [ -z "${2:-}" ]; then
        log_error "Usage: $0 validate <terraform_dir>"
        exit 1
      fi
      validate_terraform "$2"
      ;;
    *)
      echo "Usage: $0 {lambda|validate} [arguments]"
      echo ""
      echo "Commands:"
      echo "  lambda <source_dir> <output_zip>  - Build Lambda deployment package"
      echo "  validate <terraform_dir>          - Validate Terraform configuration"
      exit 1
      ;;
  esac
}

main "$@"
