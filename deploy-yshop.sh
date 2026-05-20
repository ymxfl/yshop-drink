#!/usr/bin/env bash
# YShop 部署：后端 jar + 管理端 Vue + UniApp H5
# 用法: ./deploy-yshop.sh [setup|init-db|build|deploy|all|status]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ ! -f "$ROOT/deploy-config.sh" ]]; then
  echo "请先复制 deploy-config.example.sh 为 deploy-config.sh 并填写配置"
  exit 1
fi
# shellcheck source=/dev/null
source "$ROOT/deploy-config.sh"

BOOT="$ROOT/yshop-drink-boot3"
VUE="$ROOT/yshop-drink-vue3"
UNI="$ROOT/yshop-drink-uniapp-vue3"
SSH_APP=(ssh -i "$APP_SSH_KEY" -p "$APP_SSH_PORT" -o BatchMode=yes "${APP_SSH_USER}@${APP_SSH_HOST}")
SSH_DB=(ssh -i "$DB_SSH_KEY" -p "$DB_SSH_PORT" -o BatchMode=yes "${DB_SSH_USER}@${DB_SSH_HOST}")
RSYNC_APP=(rsync -avz --delete -e "ssh -i $APP_SSH_KEY -p $APP_SSH_PORT -o BatchMode=yes")
RSYNC_DB=(rsync -avz -e "ssh -i $DB_SSH_KEY -p $DB_SSH_PORT -o BatchMode=yes")

MYSQL_BIN="${MYSQL_BIN:-/home/mysql/mysql8/bin/mysql}"
MYSQL_SOCKET="${MYSQL_SOCKET:-/home/mysql/mysql8/mysql.sock}"

app_remote() { "${SSH_APP[@]}" "$@"; }
db_remote() { "${SSH_DB[@]}" "$@"; }

setup_java17() {
  app_remote bash -s <<'REMOTE'
set -e
JAVA_LINK=/usr/lib/jvm/java-17-openjdk
if [[ -x "$JAVA_LINK/bin/java" ]]; then
  "$JAVA_LINK/bin/java" -version
  exit 0
fi
yum install -y wget tar gzip 2>/dev/null || true
JDK_DIR=/opt/jdk-17
if [[ ! -x "$JDK_DIR/bin/java" ]]; then
  rm -rf "$JDK_DIR"
  mkdir -p /opt
  TAR=/tmp/temurin17.tar.gz
  wget -q -O "$TAR" "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.14_7.tar.gz" \
    || wget -q -O "$TAR" "https://mirrors.tuna.tsinghua.edu.cn/Adoptium/17/jdk/x64/linux/OpenJDK17U-jdk_x64_linux_hotspot_17.0.14_7.tar.gz"
  tar -xzf "$TAR" -C /opt
  rm -f "$TAR"
  EXTRACTED=$(find /opt -maxdepth 1 -type d -name 'jdk-17*' | head -1)
  mv "$EXTRACTED" "$JDK_DIR"
fi
mkdir -p /usr/lib/jvm
ln -sfn "$JDK_DIR" "$JAVA_LINK"
"$JAVA_LINK/bin/java" -version
REMOTE
}

setup_dirs() {
  app_remote bash -s <<REMOTE
set -e
mkdir -p /opt/yshop-drink/{logs,file}
mkdir -p /home/nginx2/nginx/yshop-drink/{admin,h5}
mkdir -p /home/nginx2/nginx/conf/includes
REMOTE
}

install_nginx() {
  local ssl_zip="$ROOT/docs/wine.joshuatech.cn_nginx.zip"
  local ssl_src="$ROOT/deploy/ssl/wine.joshuatech.cn"
  if [[ -f "$ssl_zip" ]]; then
    mkdir -p "$ssl_src"
    unzip -oq "$ssl_zip" -d "$ROOT/deploy/ssl-tmp"
    cp -f "$ROOT/deploy/ssl-tmp/wine.joshuatech.cn_nginx/wine.joshuatech.cn_bundle.crt" "$ssl_src/"
    cp -f "$ROOT/deploy/ssl-tmp/wine.joshuatech.cn_nginx/wine.joshuatech.cn.key" "$ssl_src/"
    rm -rf "$ROOT/deploy/ssl-tmp"
    app_remote "mkdir -p /home/nginx2/nginx/conf/ssl"
    "${RSYNC_APP[@]}" "$ssl_src/wine.joshuatech.cn_bundle.crt" \
      "${APP_SSH_USER}@${APP_SSH_HOST}:/home/nginx2/nginx/conf/ssl/wine.joshuatech.cn_bundle.crt"
    "${RSYNC_APP[@]}" "$ssl_src/wine.joshuatech.cn.key" \
      "${APP_SSH_USER}@${APP_SSH_HOST}:/home/nginx2/nginx/conf/ssl/wine.joshuatech.cn.key"
    app_remote "chmod 600 /home/nginx2/nginx/conf/ssl/wine.joshuatech.cn.key"
  fi
  local nginx_conf="$ROOT/deploy/nginx-wine.joshuatech.cn.conf"
  [[ -f "$nginx_conf" ]] || nginx_conf="$ROOT/deploy/nginx-yshop.conf"
  "${RSYNC_APP[@]}" "$nginx_conf" \
    "${APP_SSH_USER}@${APP_SSH_HOST}:/home/nginx2/nginx/conf/includes/yshop-drink.conf"
  app_remote bash -s <<'REMOTE'
set -e
NGINX_CONF=/home/nginx2/nginx/conf/nginx.conf
INCLUDE_MARKER='# yshop-drink include'
if ! grep -qF "$INCLUDE_MARKER" "$NGINX_CONF"; then
  sed -i "/^http {/a\\    include includes/yshop-drink.conf; $INCLUDE_MARKER" "$NGINX_CONF"
fi
/home/nginx2/nginx/sbin/nginx -t
/home/nginx2/nginx/sbin/nginx -s reload
REMOTE
}

install_systemd() {
  "${RSYNC_APP[@]}" "$ROOT/deploy/yshop-server.service" \
    "${APP_SSH_USER}@${APP_SSH_HOST}:/etc/systemd/system/yshop-server.service"
  app_remote "systemctl daemon-reload && systemctl enable yshop-server"
}

push_secrets() {
  local secret
  secret=$(mktemp)
  trap 'rm -f "$secret"' RETURN
  cat >"$secret" <<EOF
spring:
  datasource:
    dynamic:
      datasource:
        master:
          password: ${MYSQL_PASSWORD}
        slave:
          password: ${MYSQL_PASSWORD}
  data:
    redis:
      password: ${REDIS_PASSWORD}
EOF
  "${RSYNC_APP[@]}" "$secret" "${APP_SSH_USER}@${APP_SSH_HOST}:/opt/yshop-drink/application-secret.yaml"
}

init_db() {
  echo ">>> 初始化 MySQL（${MYSQL_HOST}:${MYSQL_PORT}，实例 ${MYSQL_HOME}）..."
  local sql="$BOOT/sql/yixiang-drink-open.sql"
  [[ -f "$sql" ]] || { echo "缺少 $sql"; exit 1; }

  # 优先：SSH 到 DB 机，用 mysql 用户目录下的客户端 + socket
  if "${SSH_DB[@]}" "${MYSQL_BIN} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' -S ${MYSQL_SOCKET} -e 'SELECT 1'" &>/dev/null; then
    echo "在 DB 服务器上通过 ${MYSQL_SOCKET} 建库导入..."
    "${RSYNC_DB[@]}" "$sql" "${DB_SSH_USER}@${DB_SSH_HOST}:/tmp/yixiang-drink-open.sql"
    db_remote bash -s <<REMOTE
set -e
${MYSQL_BIN} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' -S ${MYSQL_SOCKET} -e "CREATE DATABASE IF NOT EXISTS \\\`${MYSQL_DATABASE}\\\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
${MYSQL_BIN} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' -S ${MYSQL_SOCKET} ${MYSQL_DATABASE} < /tmp/yixiang-drink-open.sql
rm -f /tmp/yixiang-drink-open.sql
echo db_import_ok
REMOTE
    return 0
  fi

  # 备选：从应用服务器 TCP 连接（端口一般为 3336，非 3306）
  if "${SSH_APP[@]}" "mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' -e 'SELECT 1'" &>/dev/null; then
    echo "在应用服务器 ${APP_SSH_HOST} 上远程建库导入..."
    "${RSYNC_APP[@]}" "$sql" "${APP_SSH_USER}@${APP_SSH_HOST}:/tmp/yixiang-drink-open.sql"
    app_remote bash -s <<REMOTE
set -e
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' -e "CREATE DATABASE IF NOT EXISTS \\\`${MYSQL_DATABASE}\\\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p'${MYSQL_PASSWORD}' ${MYSQL_DATABASE} < /tmp/yixiang-drink-open.sql
rm -f /tmp/yixiang-drink-open.sql
echo db_import_ok
REMOTE
    return 0
  fi

  echo "无法连接 MySQL。请确认 SSH ${DB_SSH_HOST}:${DB_SSH_PORT} 或 ${MYSQL_HOST}:${MYSQL_PORT} 可达"
  exit 1
}

build_boot() {
  echo ">>> 构建后端 jar..."
  export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 17 2>/dev/null || true)}"
  if [[ -z "${JAVA_HOME:-}" ]]; then
    echo "请安装 JDK 17 并设置 JAVA_HOME"
    exit 1
  fi
  (cd "$BOOT" && mvn -pl yshop-server -am package -DskipTests -q)
  [[ -f "$BOOT/yshop-server/target/yshop-server.jar" ]] || {
    echo "jar 构建失败"
    exit 1
  }
}

build_vue() {
  echo ">>> 构建管理端..."
  (cd "$VUE" && pnpm install --frozen-lockfile 2>/dev/null || pnpm install)
  (cd "$VUE" && \
    VITE_DEPLOY_BUILD=1 \
    VITE_BASE_URL="${PUBLIC_URL:-https://${PUBLIC_HOST}}" \
    VITE_UPLOAD_URL="${PUBLIC_URL:-https://${PUBLIC_HOST}}/admin-api/infra/file/upload" \
    VITE_API_URL="/admin-api" \
    VITE_BASE_PATH="/admin/" \
    VITE_MALL_H5_DOMAIN="${PUBLIC_URL:-https://${PUBLIC_HOST}}/h5" \
    pnpm build:prod)
  [[ -d "$VUE/dist-prod" ]] || { echo "dist-prod 不存在"; exit 1; }
}

build_uni() {
  echo ">>> 构建 UniApp H5..."
  (cd "$UNI" && pnpm install --frozen-lockfile 2>/dev/null || pnpm install)
  (cd "$UNI" && pnpm build:h5)
  local h5dist="$UNI/dist/build/h5"
  [[ -d "$h5dist" ]] || h5dist="$UNI/dist/dev/h5"
  [[ -d "$h5dist" ]] || { echo "H5 构建输出目录未找到"; exit 1; }
  echo "$h5dist"
}

deploy_boot() {
  echo ">>> 部署后端..."
  "${RSYNC_APP[@]}" "$BOOT/yshop-server/target/yshop-server.jar" \
    "${APP_SSH_USER}@${APP_SSH_HOST}:/opt/yshop-drink/yshop-server.jar"
  push_secrets
  app_remote "systemctl restart yshop-server || systemctl start yshop-server"
  sleep 5
  app_remote "curl -sf http://127.0.0.1:${SERVER_PORT}/actuator/health || (journalctl -u yshop-server -n 40 --no-pager; exit 1)"
}

deploy_vue() {
  echo ">>> 部署管理端静态资源..."
  local tar="/tmp/yshop-admin.tar.gz"
  (cd "$VUE/dist-prod" && tar czf "$tar" .)
  "${RSYNC_APP[@]}" "$tar" "${APP_SSH_USER}@${APP_SSH_HOST}:/tmp/yshop-admin.tar.gz"
  app_remote "mkdir -p ${SERVER_ADMIN_DIST} && rm -rf ${SERVER_ADMIN_DIST}/* && tar xzf /tmp/yshop-admin.tar.gz -C ${SERVER_ADMIN_DIST} && rm -f /tmp/yshop-admin.tar.gz"
  rm -f "$tar"
}

deploy_uni() {
  local h5dist="${1:-}"
  if [[ -z "$h5dist" ]]; then
    h5dist=$(build_uni)
  fi
  echo ">>> 部署 H5 ($h5dist)..."
  local tar="/tmp/yshop-h5.tar.gz"
  (cd "$h5dist" && tar czf "$tar" .)
  "${RSYNC_APP[@]}" "$tar" "${APP_SSH_USER}@${APP_SSH_HOST}:/tmp/yshop-h5.tar.gz"
  app_remote "mkdir -p ${SERVER_H5_DIST} && rm -rf ${SERVER_H5_DIST}/* && tar xzf /tmp/yshop-h5.tar.gz -C ${SERVER_H5_DIST} && rm -f /tmp/yshop-h5.tar.gz"
  rm -f "$tar"
}

setup_ssh_db() {
  if [[ -z "${DB_SSH_PASSWORD:-}" ]]; then return 0; fi
  local pub
  pub=$(cat "$DB_SSH_KEY.pub")
  sshpass -p "$DB_SSH_PASSWORD" ssh -o StrictHostKeyChecking=accept-new -p "$DB_SSH_PORT" \
    "${DB_SSH_USER}@${DB_SSH_HOST}" \
    "mkdir -p ~/.ssh && grep -qF '${pub}' ~/.ssh/authorized_keys 2>/dev/null || echo '${pub}' >> ~/.ssh/authorized_keys" \
    && echo "DB 服务器密钥已配置" || echo "DB 服务器 SSH 仍不可用，跳过"
}

status_cmd() {
  app_remote "systemctl is-active yshop-server 2>/dev/null || echo inactive; curl -sI http://127.0.0.1/admin/ | head -3"
}

cmd="${1:-all}"
case "$cmd" in
  setup)
    setup_ssh_db
    setup_java17
    setup_dirs
    install_nginx
    install_systemd
    push_secrets
    ;;
  init-db) init_db ;;
  build)
    build_boot
    build_vue
    build_uni >/dev/null
    ;;
  deploy)
    deploy_boot
    deploy_vue
    deploy_uni
    install_nginx
    ;;
  all)
    setup_ssh_db
    setup_java17
    setup_dirs
    install_systemd
    push_secrets
    install_nginx
    init_db || echo "警告: 数据库未导入，后端可能无法启动"
    build_boot
    build_vue
    H5_DIST=$(build_uni)
    deploy_boot || echo "警告: 后端未就绪（多为数据库未连通）"
    deploy_vue
    deploy_uni "$H5_DIST"
    ;;
  status) status_cmd ;;
  *)
    echo "用法: $0 [setup|init-db|build|deploy|all|status]"
    exit 1
    ;;
esac

echo ">>> 完成: ${PUBLIC_URL:-https://${PUBLIC_HOST}}/admin/  |  ${PUBLIC_URL:-https://${PUBLIC_HOST}}/h5/"
