#!/bin/bash
# 
# Compiles JSON to define an AWS Fargate task
#
# This is a workaround until Terraform 0.12 releases with sufficiently versatile template
# processing.
#
# Dependencies:
#
# - jq
#
# Usage:
#
# $ ./definition.sh '{ "name": "hello-world", "image_repository_url": "aws_account_id.dkr.ecr.region.amazonaws.com/hello-world", "image_tag": "latest", "log_group": "/aws/ecs/hello-world", "region": "us-west-1", "environment": { "ENV_VAR_1": "foo", "ENV_VAR_2": "bar" }, "secrets": {}}'
#

set -euo pipefail

INPUT="$1"

name="$(echo "$INPUT" | jq -r .name )"
image_repository_url="$(echo "$INPUT" | jq -r .image_repository_url )"
image_tag="$(echo "$INPUT" | jq -r .image_tag )"
log_group="$(echo "$INPUT" | jq -r .log_group )"
region="$(echo "$INPUT" | jq -r .region )"
environment="$(echo "$INPUT" | jq '.environment | to_entries | map({name: .key, value: .value})')"
secrets="$(echo "$INPUT" | jq '.secrets | to_entries | map({name: .key, valueFrom: .value})')"

image="$image_repository_url:$image_tag"

rendered="$(cat <<EOF
[
  {
    "name": "${name}",
    "image": "${image}",
    "networkMode": "awsvpc",
    "essential": true,
    "environment": ${environment},
    "secrets": ${secrets},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
)"

jq -n --arg rendered "$(echo $rendered | jq .)" '{"rendered":$rendered}'
