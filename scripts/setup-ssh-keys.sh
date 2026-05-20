#!/usr/bin/env bash
# 首次运行：将 deploy 公钥写入两台服务器（需 deploy-config.sh 中的密码）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/deploy-config.sh"

KEY="${APP_SSH_KEY:-$HOME/.ssh/id_ed25519_yshop_deploy}"
[[ -f "$KEY" ]] || ssh-keygen -t ed25519 -f "$KEY" -N "" -C "yshop-drink-deploy"
PUB=$(cat "${KEY}.pub")

sshpass -p "$APP_SSH_PASSWORD" ssh -o StrictHostKeyChecking=accept-new -p "$APP_SSH_PORT" \
  "${APP_SSH_USER}@${APP_SSH_HOST}" \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && grep -qF '$PUB' ~/.ssh/authorized_keys 2>/dev/null || echo '$PUB' >> ~/.ssh/authorized_keys"

if [[ -n "${DB_SSH_PASSWORD:-}" ]]; then
  sshpass -p "$DB_SSH_PASSWORD" ssh -o StrictHostKeyChecking=accept-new -p "$DB_SSH_PORT" \
    "${DB_SSH_USER}@${DB_SSH_HOST}" \
    "mkdir -p ~/.ssh && chmod 700 ~/.ssh && grep -qF '$PUB' ~/.ssh/authorized_keys 2>/dev/null || echo '$PUB' >> ~/.ssh/authorized_keys" \
    && echo "DB 服务器 OK" || echo "DB 服务器 SSH 失败，请检查 3344 端口/防火墙"
fi

echo "公钥: $PUB"
echo "测试 229: ssh -i $KEY -p $APP_SSH_PORT ${APP_SSH_USER}@${APP_SSH_HOST} echo ok"
