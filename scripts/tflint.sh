#!/bin/bash

# This script is used to lint the codebase.
set -e

# if tflint not installed, install it
if ! [ -x "$(command -v tflint)" ]; then
  echo 'tflint not installed, installing...'
  # If go is not installed, install it.
  if ! command -v go > /dev/null; then
    echo "Go is not installed. Required to download tf-linter."
    exit 1
  fi
  go get -u github.com/golang/lint/golint
fi

# run tflint, supply path to the directory containing the codebase

tflint --enable-rule=terraform_comment_syntax \
  --enable-rule=terraform_deprecated_index \
  --enable-rule=terraform_documented_outputs \
  --enable-rule=terraform_documented_variables \
  --enable-rule=terraform_naming_convention \
  --enable-rule=terraform_standard_module_structure \
  --enable-rule=terraform_typed_variables \
  --enable-rule=terraform_unused_declarations \
  --enable-rule=terraform_unused_required_providers \
  "$@"
