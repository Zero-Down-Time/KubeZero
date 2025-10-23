#!/bin/bash

# AI Bot Blocker Pattern Generator
# Converts HAProxy AI bot list to regex pattern blocks to stay under Istio limit

set -euo pipefail

URL="https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/haproxy-block-ai-bots.txt"
TEMP_FILE=$(mktemp)
MAX_BYTES=1000

# Download and clean the bot list
curl -s "$URL" | grep -v '^#' | grep -v '^$' | sort -u > "$TEMP_FILE"

# Function to escape regex special characters
escape_regex() {
    echo "$1" | sed 's/[[\.*^$()+?{|]/\\&/g'
}

# Function to calculate byte length of a string
byte_length() {
    echo -n "$1" | wc -c
}

# Initialize variables
current_patterns=""
block_count=1
header_template="    - headers:
        user-agent:
          regex: '(?i).*(?:"

while IFS= read -r bot_name; do
    # Skip empty lines
    [[ -z "$bot_name" ]] && continue

    # Escape the bot name for regex
    escaped_bot=$(escape_regex "$bot_name")

    # Calculate the size of the new pattern addition
    if [[ -z "$current_patterns" ]]; then
        new_pattern="$escaped_bot"
    else
        new_pattern="$current_patterns|$escaped_bot"
    fi

    # Calculate total block size including template
    full_block="$header_template$new_pattern).*'"
    block_size=$(byte_length "$full_block")

    # Check if adding this pattern would exceed the limit
    if [[ $block_size -gt $MAX_BYTES ]] && [[ -n "$current_patterns" ]]; then
        # Output current block
        echo "$header_template$current_patterns).*'"

        # Start new block
        current_patterns="$escaped_bot"
        ((block_count++))
    else
        # Add pattern to current block
        current_patterns="$new_pattern"
    fi

done < "$TEMP_FILE"

# Output final block if not empty
if [[ -n "$current_patterns" ]]; then
    echo "$header_template$current_patterns).*'"
fi

# Cleanup
rm "$TEMP_FILE"
