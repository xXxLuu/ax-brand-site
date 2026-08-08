#!/usr/bin/env bash
set -Eeuo pipefail

DOMAIN="${1:-axmoonlight.com}"
SOURCE_DIR="${2:-/root/ax-website}"
SITE_DIR="/var/www/${DOMAIN}"
CONFIG_TEMPLATE="${SOURCE_DIR}/deploy/nginx/axmoonlight.com.conf"
CONFIG_FILE="/etc/nginx/conf.d/${DOMAIN}.conf"

if [[ "${EUID}" -ne 0 ]]; then
  echo "请使用 root 账号执行，或使用 sudo。" >&2
  exit 1
fi

for required_file in index.html brand.css style.css script.js; do
  if [[ ! -f "${SOURCE_DIR}/${required_file}" ]]; then
    echo "找不到网站文件：${SOURCE_DIR}/${required_file}" >&2
    exit 1
  fi
done

if [[ ! -d "${SOURCE_DIR}/assets" || ! -f "${CONFIG_TEMPLATE}" ]]; then
  echo "网站素材或 Nginx 配置缺失。" >&2
  exit 1
fi

if command -v dnf >/dev/null 2>&1; then
  dnf install -y nginx rsync
elif command -v yum >/dev/null 2>&1; then
  yum install -y nginx rsync
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y nginx rsync
else
  echo "未识别服务器的软件包管理器，请手动安装 Nginx 和 rsync。" >&2
  exit 1
fi

WEB_USER="nginx"
if ! id "${WEB_USER}" >/dev/null 2>&1; then
  WEB_USER="www-data"
fi
if ! id "${WEB_USER}" >/dev/null 2>&1; then
  WEB_USER="root"
fi

install -d -m 0755 -o "${WEB_USER}" -g "${WEB_USER}" "${SITE_DIR}"
rsync -a --delete "${SOURCE_DIR}/assets/" "${SITE_DIR}/assets/"
install -m 0644 "${SOURCE_DIR}/index.html" "${SITE_DIR}/index.html"
install -m 0644 "${SOURCE_DIR}/brand.css" "${SITE_DIR}/brand.css"
install -m 0644 "${SOURCE_DIR}/style.css" "${SITE_DIR}/style.css"
install -m 0644 "${SOURCE_DIR}/script.js" "${SITE_DIR}/script.js"
install -m 0644 "${SOURCE_DIR}/favicon.svg" "${SITE_DIR}/favicon.svg"
chown -R "${WEB_USER}:${WEB_USER}" "${SITE_DIR}"

sed "s/__DOMAIN__/${DOMAIN}/g" "${CONFIG_TEMPLATE}" > "${CONFIG_FILE}"
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "网站已部署： http://${DOMAIN}"
