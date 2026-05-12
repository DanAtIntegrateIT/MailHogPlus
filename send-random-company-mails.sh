#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./send-random-company-mails.sh [count]

Sends random test emails to MailHogPlus using random company usernames.
Email types are mixed: plain text, HTML, and attachment messages.

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

append_line() {
  local file="$1"
  local line="$2"
  printf '%s\r\n' "$line" >>"$file"
}

append_blank() {
  local file="$1"
  printf '\r\n' >>"$file"
}

build_plain_email() {
  local file="$1"
  local company="$2"
  local username="$3"
  local recipient="$4"
  local run_id="$5"
  local index="$6"
  local total="$7"
  local from_addr="$8"

  : >"$file"
  append_line "$file" "Subject: [${company}] MailHogPlus Seed ${run_id} #${index} (plain)"
  append_line "$file" "From: MailHogPlus Seeder <${from_addr}>"
  append_line "$file" "To: ${recipient}"
  append_line "$file" "MIME-Version: 1.0"
  append_line "$file" "Content-Type: text/plain; charset=utf-8"
  append_blank "$file"
  append_line "$file" "Automated MailHogPlus test message."
  append_line "$file" "Format: plain text"
  append_line "$file" "Company: ${company}"
  append_line "$file" "SMTP Username: ${username}"
  append_line "$file" "Run ID: ${run_id}"
  append_line "$file" "Message: ${index}/${total}"
}

build_html_email() {
  local file="$1"
  local company="$2"
  local username="$3"
  local recipient="$4"
  local run_id="$5"
  local index="$6"
  local total="$7"
  local from_addr="$8"
  local boundary_alt="ALT-${run_id//[^a-zA-Z0-9]/}-${index}"

  : >"$file"
  append_line "$file" "Subject: [${company}] MailHogPlus Seed ${run_id} #${index} (html)"
  append_line "$file" "From: MailHogPlus Seeder <${from_addr}>"
  append_line "$file" "To: ${recipient}"
  append_line "$file" "MIME-Version: 1.0"
  append_line "$file" "Content-Type: multipart/alternative; boundary=\"${boundary_alt}\""
  append_blank "$file"
  append_line "$file" "--${boundary_alt}"
  append_line "$file" "Content-Type: text/plain; charset=utf-8"
  append_line "$file" "Content-Transfer-Encoding: 7bit"
  append_blank "$file"
  append_line "$file" "Automated MailHogPlus HTML test message."
  append_line "$file" "Company: ${company}"
  append_line "$file" "SMTP Username: ${username}"
  append_line "$file" "Run ID: ${run_id}"
  append_line "$file" "Message: ${index}/${total}"
  append_blank "$file"
  append_line "$file" "--${boundary_alt}"
  append_line "$file" "Content-Type: text/html; charset=utf-8"
  append_line "$file" "Content-Transfer-Encoding: 7bit"
  append_blank "$file"
  append_line "$file" "<!doctype html>"
  append_line "$file" "<html><body>"
  append_line "$file" "<h2>MailHogPlus HTML seed</h2>"
  append_line "$file" "<p><strong>Company:</strong> ${company}</p>"
  append_line "$file" "<p><strong>SMTP Username:</strong> ${username}</p>"
  append_line "$file" "<p><strong>Run ID:</strong> ${run_id}</p>"
  append_line "$file" "<p><strong>Message:</strong> ${index}/${total}</p>"
  append_line "$file" "</body></html>"
  append_blank "$file"
  append_line "$file" "--${boundary_alt}--"
}

build_attachment_email() {
  local file="$1"
  local company="$2"
  local username="$3"
  local recipient="$4"
  local run_id="$5"
  local index="$6"
  local total="$7"
  local from_addr="$8"
  local include_html="$9"
  local boundary_mixed="MIXED-${run_id//[^a-zA-Z0-9]/}-${index}"
  local attachment_name="seed-${username}-${index}.csv"
  local attachment_csv attachment_payload

  attachment_csv="company,username,run_id,message_index,total_messages
${company},${username},${run_id},${index},${total}"
  attachment_payload="$(printf '%s' "$attachment_csv" | base64 | tr -d '\r\n')"

  : >"$file"
  append_line "$file" "Subject: [${company}] MailHogPlus Seed ${run_id} #${index} (attachment)"
  append_line "$file" "From: MailHogPlus Seeder <${from_addr}>"
  append_line "$file" "To: ${recipient}"
  append_line "$file" "MIME-Version: 1.0"
  append_line "$file" "Content-Type: multipart/mixed; boundary=\"${boundary_mixed}\""
  append_blank "$file"
  append_line "$file" "--${boundary_mixed}"
  append_line "$file" "Content-Type: text/plain; charset=utf-8"
  append_line "$file" "Content-Transfer-Encoding: 7bit"
  append_blank "$file"
  append_line "$file" "Automated MailHogPlus attachment test message."
  append_line "$file" "Company: ${company}"
  append_line "$file" "SMTP Username: ${username}"
  append_line "$file" "Run ID: ${run_id}"
  append_line "$file" "Message: ${index}/${total}"
  append_line "$file" "Attachment: ${attachment_name}"

  if [[ "$include_html" == "yes" ]]; then
    append_blank "$file"
    append_line "$file" "--${boundary_mixed}"
    append_line "$file" "Content-Type: text/html; charset=utf-8"
    append_line "$file" "Content-Transfer-Encoding: 7bit"
    append_blank "$file"
    append_line "$file" "<!doctype html>"
    append_line "$file" "<html><body>"
    append_line "$file" "<h2>MailHogPlus attachment seed</h2>"
    append_line "$file" "<p><strong>Company:</strong> ${company}</p>"
    append_line "$file" "<p><strong>Attachment:</strong> ${attachment_name}</p>"
    append_line "$file" "</body></html>"
  fi

  append_blank "$file"
  append_line "$file" "--${boundary_mixed}"
  append_line "$file" "Content-Type: text/csv; name=\"${attachment_name}\""
  append_line "$file" "Content-Disposition: attachment; filename=\"${attachment_name}\""
  append_line "$file" "Content-Transfer-Encoding: base64"
  append_blank "$file"

  while [[ -n "$attachment_payload" ]]; do
    append_line "$file" "${attachment_payload:0:76}"
    attachment_payload="${attachment_payload:76}"
  done

  append_blank "$file"
  append_line "$file" "--${boundary_mixed}--"
}

run_id="$(date +%Y%m%d-%H%M%S)"
from_addr="qa-bot@${FROM_DOMAIN}"
message_types=("plain" "plain" "html" "attachment" "html_attachment")

echo "Sending ${count} test email(s) to smtp://${SMTP_HOST}:${SMTP_PORT}"

for ((i = 1; i <= count; i++)); do
  entry="${companies[$((RANDOM % ${#companies[@]}))]}"
  username="${entry%%|*}"
  company="${entry#*|}"
  recipient="${username}+seed${i}@${FROM_DOMAIN}"

  msg_file="$(mktemp)"
  tmp_files+=("$msg_file")
  message_type="${message_types[$((RANDOM % ${#message_types[@]}))]}"

  case "$message_type" in
    plain)
      build_plain_email "$msg_file" "$company" "$username" "$recipient" "$run_id" "$i" "$count" "$from_addr"
      ;;
    html)
      build_html_email "$msg_file" "$company" "$username" "$recipient" "$run_id" "$i" "$count" "$from_addr"
      ;;
    attachment)
      build_attachment_email "$msg_file" "$company" "$username" "$recipient" "$run_id" "$i" "$count" "$from_addr" "no"
      ;;
    html_attachment)
      build_attachment_email "$msg_file" "$company" "$username" "$recipient" "$run_id" "$i" "$count" "$from_addr" "yes"
      ;;
  esac

  curl --silent --show-error --fail \
    --url "smtp://${SMTP_HOST}:${SMTP_PORT}" \
    --user "${username}:${SMTP_PASS}" \
    --mail-from "${from_addr}" \
    --mail-rcpt "${recipient}" \
    --upload-file "${msg_file}" >/dev/null

  echo "  [${i}/${count}] sent as '${username}' (${company}, ${message_type})"
done

echo "Done."
