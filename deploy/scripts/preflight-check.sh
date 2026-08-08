#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_DIR="${PROJECT_DIR}/deploy"
REQUIRED_FILES=(
  "index.html"
  "brand.css"
  "style.css"
  "script.js"
  "favicon.svg"
  "assets"
  "deploy/nginx/axmoonlight.com.conf"
  "deploy/scripts/deploy-to-aliyun.sh"
  "deploy/scripts/setup-server.sh"
  "deploy/scripts/enable-https.sh"
)

for relative_path in "${REQUIRED_FILES[@]}"; do
  if [[ ! -e "${PROJECT_DIR}/${relative_path}" ]]; then
    echo "缺少上线文件：${relative_path}" >&2
    exit 1
  fi
done

for script in "${DEPLOY_DIR}"/scripts/*.sh; do
  bash -n "${script}"
done

if ! command -v npm >/dev/null 2>&1; then
  echo "未找到 npm，无法执行网站构建检查。" >&2
  exit 1
fi

(
  cd "${PROJECT_DIR}"
  npm run build >/dev/null
)

asset_count="$(find "${PROJECT_DIR}/assets" -type f | wc -l | tr -d ' ')"

echo "上线前检查通过"
echo "网站域名：axmoonlight.com"
echo "素材文件：${asset_count} 个"
echo "备案通过后执行：bash deploy/scripts/deploy-to-aliyun.sh root@服务器公网IP"
