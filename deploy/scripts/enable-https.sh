#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "用法：bash deploy/scripts/enable-https.sh root@服务器公网IP 你的常用邮箱" >&2
  exit 1
fi

REMOTE_HOST="$1"
EMAIL="$2"
DOMAIN="axmoonlight.com"

ssh "${REMOTE_HOST}" "DOMAIN='${DOMAIN}' EMAIL='${EMAIL}' bash -s" <<'REMOTE_SCRIPT'
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "请使用 root 账号执行，或使用 sudo。" >&2
  exit 1
fi

if command -v dnf >/dev/null 2>&1; then
  dnf install -y certbot python3-certbot-nginx
elif command -v yum >/dev/null 2>&1; then
  yum install -y epel-release
  yum install -y certbot python3-certbot-nginx
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python3-certbot-nginx
else
  echo "未识别服务器的软件包管理器。" >&2
  exit 1
fi

certbot --nginx --non-interactive --agree-tos --redirect \
  --email "${EMAIL}" \
  -d "${DOMAIN}" \
  -d "www.${DOMAIN}"

systemctl enable certbot-renew.timer 2>/dev/null || true
echo "HTTPS 已启用：https://${DOMAIN}"
REMOTE_SCRIPT
