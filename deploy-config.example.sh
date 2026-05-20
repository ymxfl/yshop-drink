#!/bin/bash
# 复制为 deploy-config.sh 并填写真实信息（deploy-config.sh 已加入 .gitignore）

# 应用服务器 (Nginx / Redis / Java)
APP_SSH_USER="root"
APP_SSH_HOST="117.72.32.229"
APP_SSH_PORT="22"
APP_SSH_KEY="$HOME/.ssh/id_ed25519_yshop_deploy"

# MySQL 服务器
DB_SSH_USER="root"
DB_SSH_HOST="1.117.62.160"
DB_SSH_PORT="3344"
DB_SSH_KEY="$HOME/.ssh/id_ed25519_yshop_deploy"

# MySQL（应用服务器连接用）
MYSQL_HOST="1.117.62.160"
MYSQL_PORT="3336"
MYSQL_USER="root"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DATABASE="yixiang-drink-open"
MYSQL_HOME="/home/mysql/mysql8"
MYSQL_BIN="${MYSQL_HOME}/bin/mysql"
MYSQL_SOCKET="${MYSQL_HOME}/mysql.sock"

# Redis（在应用服务器本机）
REDIS_HOST="127.0.0.1"
REDIS_PORT="9736"
REDIS_PASSWORD="your_redis_password"
REDIS_DATABASE="0"

# 服务器目录
SERVER_APP_ROOT="/opt/yshop-drink"
SERVER_JAR_NAME="yshop-server.jar"
SERVER_NGINX_BIN="/home/nginx2/nginx/sbin/nginx"
SERVER_ADMIN_DIST="/home/nginx2/nginx/yshop-drink/admin"
SERVER_H5_DIST="/home/nginx2/nginx/yshop-drink/h5"

# 公网访问（用于前端打包）
PUBLIC_HOST="wine.joshuatech.cn"
PUBLIC_URL="https://wine.joshuatech.cn"
SPRING_PROFILE="prod"
SERVER_PORT="48081"
