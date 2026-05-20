#!/usr/bin/env bash
# yshop-drink 三端本地开发启动脚本
# 支持单独或组合启动：后端(boot)、管理后台(vue)、移动端(uni)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_DIR="$ROOT_DIR/yshop-drink-boot3"
VUE_DIR="$ROOT_DIR/yshop-drink-vue3"
UNI_DIR="$ROOT_DIR/yshop-drink-uniapp-vue3"

LOG_DIR="$ROOT_DIR/.dev-logs"
PID_DIR="$ROOT_DIR/.dev-pids"

SPRING_PROFILE="${SPRING_PROFILE:-local}"
UNI_PLATFORM="${UNI_PLATFORM:-h5}"  # h5 | mp-weixin
FOREGROUND=false
DO_INSTALL=false
BOOT_LIVE=false  # true 时用 mvn spring-boot:run 热更新；默认用已编译 jar 启动更快

# 颜色
if [[ -t 1 ]]; then
  C_RESET='\033[0m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[1;33m'
  C_RED='\033[0;31m'
  C_CYAN='\033[0;36m'
else
  C_RESET='' C_GREEN='' C_YELLOW='' C_RED='' C_CYAN=''
fi

info()  { echo -e "${C_GREEN}[INFO]${C_RESET} $*"; }
warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
error() { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; }

usage() {
  cat <<'EOF'
yshop-drink 三端开发启动脚本

用法:
  ./start.sh <服务...> [选项]
  ./start.sh stop [服务...]
  ./start.sh status
  ./start.sh logs [服务]

服务（可组合，空格分隔）:
  boot, backend, server    后端 Java (Spring Boot)     默认端口 48081 (local)
  vue, admin, web          管理后台 Vue3               默认端口 8080
  uni, uniapp, mobile      移动端 UniApp               h5 或微信小程序
  all                      启动以上三端

命令:
  stop [服务...]           停止服务；不指定则停止全部
  status                   查看运行状态
  logs [服务]              查看日志；不指定则列出日志文件

选项:
  -f, --foreground         前台运行（仅支持单端）
  -i, --install            启动前安装依赖
  --profile <name>         Spring 配置 (默认: local)
  --h5                     UniApp 以 H5 模式启动（默认）
  --mp                     UniApp 以微信小程序模式启动
  --live                   后端使用 mvn spring-boot:run（需 JDK 17，适合改代码后调试）
  -h, --help               显示帮助

示例:
  ./start.sh boot                    # 仅启动后端
  ./start.sh vue uni                 # 启动管理后台 + 移动端
  ./start.sh all                     # 启动三端
  ./start.sh all -i                  # 安装依赖后启动三端
  ./start.sh boot -f                 # 后端前台运行（可看实时日志）
  ./start.sh uni --mp                # 微信小程序开发模式
  ./start.sh stop vue                # 停止管理后台
  ./start.sh logs boot               # 查看后端日志

环境要求: JDK 17, Maven 3.8+, Node 16+, pnpm(管理后台), MySQL, Redis
EOF
}

normalize_service() {
  case "$1" in
    boot|backend|server) echo "boot" ;;
    vue|admin|web)       echo "vue" ;;
    uni|uniapp|mobile|miniapp) echo "uni" ;;
    all)                 echo "all" ;;
    *)                   return 1 ;;
  esac
}

require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    error "未找到命令: $1，请先安装"
    exit 1
  fi
}

mkdir -p "$LOG_DIR" "$PID_DIR"

pid_file() { echo "$PID_DIR/$1.pid"; }
log_file() { echo "$LOG_DIR/$1.log"; }

is_running() {
  local name="$1"
  local pf
  pf="$(pid_file "$name")"
  if [[ -f "$pf" ]]; then
    local pid
    pid="$(cat "$pf")"
    if kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    rm -f "$pf"
  fi
  return 1
}

stop_service() {
  local name="$1"
  local pf
  pf="$(pid_file "$name")"
  if ! [[ -f "$pf" ]]; then
    warn "$name 未在运行"
    return 0
  fi
  local pid
  pid="$(cat "$pf")"
  if kill -0 "$pid" 2>/dev/null; then
    info "停止 $name (PID $pid) ..."
    local pgid
    pgid="$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
    kill -TERM "$pid" 2>/dev/null || true
    if [[ -n "${pgid:-}" && "$pgid" != "$$" ]]; then
      kill -TERM "-$pgid" 2>/dev/null || true
    fi
    for _ in $(seq 1 15); do
      if ! kill -0 "$pid" 2>/dev/null; then
        break
      fi
      sleep 1
    done
    if kill -0 "$pid" 2>/dev/null; then
      kill -KILL "$pid" 2>/dev/null || true
      [[ -n "${pgid:-}" ]] && kill -KILL "-$pgid" 2>/dev/null || true
    fi
    info "$name 已停止"
  else
    warn "$name PID 文件存在但进程已退出，清理中"
  fi
  rm -f "$pf"
}

setup_java17() {
  if command -v /usr/libexec/java_home &>/dev/null; then
    local j17
    j17="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
    if [[ -n "$j17" ]]; then
      export JAVA_HOME="$j17"
      export PATH="$JAVA_HOME/bin:$PATH"
    fi
  fi
  if ! java -version 2>&1 | grep -qE 'version "17'; then
    warn "当前 Java 非 17，后端编译/启动可能失败（Maven 默认 JDK 与项目要求不一致）"
  fi
}

install_boot() {
  setup_java17
  info "编译后端模块（跳过测试）..."
  (cd "$BOOT_DIR" && mvn -q clean install -DskipTests -pl yshop-server -am)
  info "后端编译完成"
}

install_vue() {
  info "安装管理后台依赖 (pnpm) ..."
  if command -v pnpm &>/dev/null; then
    (cd "$VUE_DIR" && pnpm install)
  else
    warn "未找到 pnpm，使用 npm install"
    (cd "$VUE_DIR" && npm install)
  fi
}

install_uni() {
  info "安装移动端依赖 (npm) ..."
  (cd "$UNI_DIR" && npm install)
}

start_boot() {
  require_cmd java
  setup_java17
  if is_running boot; then
    warn "后端已在运行 (PID $(cat "$(pid_file boot)"))，跳过"
    return 0
  fi
  [[ "$DO_INSTALL" == true ]] && install_boot

  local log lf server_dir jar
  log="$(log_file boot)"
  lf="$(pid_file boot)"
  server_dir="$BOOT_DIR/yshop-server"
  jar="$server_dir/target/yshop-server.jar"

  info "启动后端 (profile=$SPRING_PROFILE) ..."
  info "日志: $log"

  run_boot() {
    if [[ "$BOOT_LIVE" == true ]]; then
      require_cmd mvn
      cd "$server_dir"
      exec mvn spring-boot:run \
        -Dspring-boot.run.profiles="$SPRING_PROFILE" \
        -Dmaven.test.skip=true
    elif [[ -f "$jar" ]]; then
      exec java -jar "$jar" --spring.profiles.active="$SPRING_PROFILE"
    else
      error "未找到 $jar，请先执行: ./start.sh boot -i  或  cd yshop-drink-boot3 && mvn install -DskipTests"
      exit 1
    fi
  }

  if [[ "$FOREGROUND" == true ]]; then
    run_boot
  fi

  ( run_boot ) >>"$log" 2>&1 &

  echo $! >"$lf"
  info "后端已启动 PID=$(cat "$lf")，健康检查: http://127.0.0.1:48081/actuator/health (local)"
}

start_vue() {
  require_cmd node
  if is_running vue; then
    warn "管理后台已在运行 (PID $(cat "$(pid_file vue)"))，跳过"
    return 0
  fi
  [[ "$DO_INSTALL" == true ]] && install_vue

  local log lf
  log="$(log_file vue)"
  lf="$(pid_file vue)"

  info "启动管理后台 Vue3 ..."
  info "日志: $log"

  if [[ "$FOREGROUND" == true ]]; then
    cd "$VUE_DIR"
    if command -v pnpm &>/dev/null; then
      exec pnpm run dev
    else
      exec npm run dev
    fi
  fi

  (
    cd "$VUE_DIR"
    if command -v pnpm &>/dev/null; then
      exec pnpm run dev
    else
      exec npm run dev
    fi
  ) >>"$log" 2>&1 &

  echo $! >"$lf"
  info "管理后台已启动 PID=$(cat "$lf")，访问: http://localhost:8080"
}

start_uni() {
  require_cmd node
  if is_running uni; then
    warn "移动端已在运行 (PID $(cat "$(pid_file uni)"))，跳过"
    return 0
  fi
  [[ "$DO_INSTALL" == true ]] && install_uni

  local script log lf
  case "$UNI_PLATFORM" in
    h5)        script="dev:h5" ;;
    mp-weixin) script="dev:mp-weixin" ;;
    *)
      error "不支持的 UniApp 平台: $UNI_PLATFORM (可用: h5, mp-weixin)"
      exit 1
      ;;
  esac

  log="$(log_file uni)"
  lf="$(pid_file uni)"

  info "启动移动端 UniApp ($UNI_PLATFORM) ..."
  info "日志: $log"

  if [[ "$FOREGROUND" == true ]]; then
    cd "$UNI_DIR"
    exec npm run "$script"
  fi

  (
    cd "$UNI_DIR"
    exec npm run "$script"
  ) >>"$log" 2>&1 &

  echo $! >"$lf"
  if [[ "$UNI_PLATFORM" == "h5" ]]; then
    info "移动端 H5 已启动 PID=$(cat "$lf")，端口见日志（通常 5173）"
  else
    info "微信小程序开发模式已启动 PID=$(cat "$lf")，请用微信开发者工具打开 dist/dev/mp-weixin"
  fi
}

cmd_status() {
  local names=(boot vue uni)
  local labels=("后端(Spring Boot)" "管理后台(Vue3)" "移动端(UniApp)")
  printf "%-22s %-10s %-8s %s\n" "服务" "状态" "PID" "日志"
  printf "%-22s %-10s %-8s %s\n" "----" "----" "---" "----"
  local i name
  for i in "${!names[@]}"; do
    name="${names[$i]}"
    if is_running "$name"; then
      printf "%-22s %-10s %-8s %s\n" "${labels[$i]}" "运行中" "$(cat "$(pid_file "$name")")" "$(log_file "$name")"
    else
      printf "%-22s %-10s %-8s %s\n" "${labels[$i]}" "已停止" "-" "$(log_file "$name")"
    fi
  done
}

cmd_logs() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    info "日志目录: $LOG_DIR"
    ls -la "$LOG_DIR" 2>/dev/null || true
    echo
    info "使用: ./start.sh logs <boot|vue|uni> 跟踪日志"
    return 0
  fi
  local name
  name="$(normalize_service "$target")" || { error "未知服务: $target"; exit 1; }
  local log
  log="$(log_file "$name")"
  if [[ ! -f "$log" ]]; then
    warn "日志文件不存在: $log"
    exit 1
  fi
  tail -f "$log"
}

cmd_stop() {
  local services=("$@")
  if [[ ${#services[@]} -eq 0 ]]; then
    services=(boot vue uni)
  fi
  local s name
  for s in "${services[@]}"; do
    name="$(normalize_service "$s")" || { error "未知服务: $s"; exit 1; }
    if [[ "$name" == "all" ]]; then
      stop_service boot
      stop_service vue
      stop_service uni
    else
      stop_service "$name"
    fi
  done
}

expand_all() {
  local out=()
  local s
  for s in "$@"; do
    if [[ "$s" == "all" ]]; then
      out+=(boot vue uni)
    else
      out+=("$s")
    fi
  done
  echo "${out[@]}"
}

main() {
  if [[ $# -eq 0 ]]; then
    usage
    exit 0
  fi

  local command=""
  local -a positional=()
  local arg

  while [[ $# -gt 0 ]]; do
    arg="$1"
    shift
    case "$arg" in
      -h|--help)
        usage
        exit 0
        ;;
      -f|--foreground)
        FOREGROUND=true
        ;;
      -i|--install)
        DO_INSTALL=true
        ;;
      --profile)
        SPRING_PROFILE="${1:?缺少 profile 参数}"
        shift
        ;;
      --h5)
        UNI_PLATFORM=h5
        ;;
      --mp)
        UNI_PLATFORM=mp-weixin
        ;;
      --live)
        BOOT_LIVE=true
        ;;
      stop|status|logs)
        command="$arg"
        positional+=("$@")
        break
        ;;
      -*)
        error "未知选项: $arg"
        usage
        exit 1
        ;;
      *)
        positional+=("$arg")
        ;;
    esac
  done

  case "${command:-start}" in
    stop)
      if [[ ${#positional[@]} -eq 0 ]]; then
        cmd_stop
      else
        local -a to_stop=()
        local s n
        for s in "${positional[@]}"; do
          n="$(normalize_service "$s")" || { error "未知服务: $s"; exit 1; }
          to_stop+=("$n")
        done
        # shellcheck disable=SC2206
        to_stop=($(expand_all "${to_stop[@]}"))
        cmd_stop "${to_stop[@]}"
      fi
      ;;
    status)
      cmd_status
      ;;
    logs)
      cmd_logs "${positional[0]:-}"
      ;;
    start)
      if [[ ${#positional[@]} -eq 0 ]]; then
        error "请指定要启动的服务，例如: ./start.sh boot  或  ./start.sh all"
        usage
        exit 1
      fi

      local -a services=()
      local s n
      for s in "${positional[@]}"; do
        n="$(normalize_service "$s")" || { error "未知服务: $s"; exit 1; }
        services+=("$n")
      done
      # shellcheck disable=SC2206
      services=($(expand_all "${services[@]}"))

      # 去重
      local -a unique=()
      local item u seen
      for item in "${services[@]}"; do
        seen=false
        for u in "${unique[@]:-}"; do
          [[ "$u" == "$item" ]] && seen=true && break
        done
        [[ "$seen" == false ]] && unique+=("$item")
      done

      if [[ "$FOREGROUND" == true && ${#unique[@]} -gt 1 ]]; then
        error "前台模式 (-f) 仅支持单端启动"
        exit 1
      fi

      info "将启动: ${unique[*]}"
      for item in "${unique[@]}"; do
        case "$item" in
          boot) start_boot ;;
          vue)  start_vue ;;
          uni)  start_uni ;;
        esac
      done

      if [[ "$FOREGROUND" == false ]]; then
        echo
        info "全部启动命令已下发。查看状态: ${C_CYAN}./start.sh status${C_RESET}"
        info "查看日志:   ${C_CYAN}./start.sh logs <boot|vue|uni>${C_RESET}"
        info "停止服务:   ${C_CYAN}./start.sh stop [服务...]${C_RESET}"
      fi
      ;;
  esac
}

main "$@"
