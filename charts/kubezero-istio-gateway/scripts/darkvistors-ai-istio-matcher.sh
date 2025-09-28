#!/bin/bash
#set -x

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ACCESS_TOKEN for darkvisitors is missing!"
  exit 1
fi

cat << EOF
  - match:
EOF

function generate_rule() {
  local agents=$1

  cat << EOF
    - headers:
        user-agent:
          regex: "(?i).*(?:$agents).*"
EOF
}

agents=""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue

  line=$(echo "$line" | tr -d '\r' | xargs)  # trim whitespace

  if [[ "$line" =~ ^[Uu]ser-[Aa]gent:[[:space:]]*(.+)$ ]]; then
    _agent="$(echo "${BASH_REMATCH[1]}" | sed 's/\*/\.\*/g' | sed 's/\./\\./g')"
    agents="$agents|$_agent"
    if [ ${#agents} -gt 900 ]; then
      generate_rule "${agents:1}"
      agents=""
    fi
  fi
done < <(curl -s -X POST https://api.darkvisitors.com/robots-txts \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
      "agent_types": [
          "AI Data Scraper",
          "Undocumented AI Agent"
      ],
      "disallow": "/"
    }')

generate_rule "${agents:1}"

# Add default allow rule
cat << EOF
    directResponse:
      status: 418
EOF
