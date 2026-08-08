#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 1 ]]; then
  echo "用法：bash deploy/scripts/deploy-to-aliyun.sh root@服务器公网IP" >&2
  exit 1
fi

REMOTE_HOST="$1"
DOMAIN="axmoonlight.com"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE="$(mktemp -t ax-moonlight-site.XXXXXX.tar.gz)"
REMOTE_DIR="/tmp/ax-moonlight-deploy"

cleanup() {
  rm -f "${ARCHIVE}"
}
trap cleanup EXIT

tar -C "${PROJECT_DIR}" \
  --exclude=.git \
  --exclude=dist \
  --exclude=.openai \
  -czf "${ARCHIVE}" \
  index.html brand.css style.css script.js favicon.svg assets deploy

scp "${ARCHIVE}" "${REMOTE_HOST}:/tmp/ax-moonlight-site.tar.gz"
ssh "${REMOTE_HOST}" "rm -rf '${REMOTE_DIR}' && mkdir -p '${REMOTE_DIR}' && tar -xzf /tmp/ax-moonlight-site.tar.gz -C '${REMOTE_DIR}' && bash '${REMOTE_DIR}/deploy/scripts/setup-server.sh' '${DOMAIN}' '${REMOTE_DIR}'"

echo "发布完成： http://${DOMAIN}"
