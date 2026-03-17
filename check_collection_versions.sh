#!/bin/bash

# make sure the pipeline fails if any command fails
set -o pipefail

# Check if requirements.yml exists
if [ ! -f "requirements.yml" ]; then
    echo "Error: requirements.yml not found"
    exit 1
fi

# Extract collection names from requirements.yml and process each one
grep -E "^\s*-\s*name:\s*" requirements.yml | sed 's/.*name:\s*//' | while read -r collection; do
    ansible-galaxy collection list "$collection" 2>/dev/null | grep -E "^$collection\s+" | sort -n | tail -n 1|| echo "$collection: Not installed or not found"
done
