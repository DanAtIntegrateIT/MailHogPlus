#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./send-random-company-mails.sh [count]

Sends random test emails to MailHogPlus using random company usernames.

Arguments:
  count                 Optional number of emails to send.
                        If omitted, a random "few" (3-6) is sent.

Environment variables:
  SMTP_HOST             SMTP host (default: localhost)
  SMTP_PORT             SMTP port (default: 1025)
  SMTP_PASS             SMTP auth password (default: testpass)
  FROM_DOMAIN           Domain for from/to addresses (default: example.com)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  if ! [[ "$1" =~ ^[0-9]+$ ]] || [[ "$1" -lt 1 ]]; then
    echo "Error: count must be a positive integer." >&2
    exit 1
  fi
  count="$1"
else
  count=$((RANDOM % 4 + 3))
fi

SMTP_HOST="${SMTP_HOST:-localhost}"
SMTP_PORT="${SMTP_PORT:-1025}"
SMTP_PASS="${SMTP_PASS:-testpass}"
FROM_DOMAIN="${FROM_DOMAIN:-example.com}"

companies=(
  "gateway|Gateway"
  "thorlux|Thorlux"
  "atlassian|Atlassian"
  "salesforce|Salesforce"
  "shopify|Shopify"
  "stripe|Stripe"
  "adobe|Adobe"
  "oracle|Oracle"
  "microsoft|Microsoft"
  "amazon|Amazon"
  "ibm|IBM"
  "siemens|Siemens"
  "zoom|Zoom"
  "xero|Xero"
  "slack|Slack"
)

tmp_files=()
cleanup() {
  for f in "${tmp_files[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"
  done
}
trap cleanup EXIT

run_id="$(date +%Y%m%d-%H%M%S)"
from_addr="qa-bot@${FROM_DOMAIN}"

echo "Sending ${count} test email(s) to smtp://${SMTP_HOST}:${SMTP_PORT}"

for ((i = 1; i <= count; i++)); do
  entry="${companies[$((RANDOM % ${#companies[@]}))]}"
  username="${entry%%|*}"
  company="${entry#*|}"
  recipient="${username}+seed${i}@${FROM_DOMAIN}"

  msg_file="$(mktemp)"
  tmp_files+=("$msg_file")

  cat >"$msg_file" <<EOF
Subject: [${company}] MailHogPlus Seed ${run_id} #${i}
From: MailHogPlus Seeder <${from_addr}>
To: ${recipient}

Automated MailHogPlus test message.
Company: ${company}
SMTP Username: ${username}
Run ID: ${run_id}
Message: ${i}/${count}
EOF

  curl --silent --show-error --fail \
    --url "smtp://${SMTP_HOST}:${SMTP_PORT}" \
    --user "${username}:${SMTP_PASS}" \
    --mail-from "${from_addr}" \
    --mail-rcpt "${recipient}" \
    --upload-file "${msg_file}" >/dev/null

  echo "  [${i}/${count}] sent as '${username}' (${company})"
done

echo "Done."
