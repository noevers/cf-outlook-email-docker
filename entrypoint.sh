#!/bin/sh
set -e

DATA_DIR="${DATA_DIR:-/app/data}"
mkdir -p "$DATA_DIR"

# 1. 确保 wrangler.toml 存在且 database_id 格式有效
if [ ! -f wrangler.toml ]; then
  echo "正在自动从 wrangler.toml.example 生成 wrangler.toml..."
  sed 's/database_id = "REPLACE_WITH_YOUR_DATABASE_ID"/database_id = "11111111-2222-3333-4444-555555555555"/' wrangler.toml.example > wrangler.toml
fi

# 2. 注入环境变量与密钥
ADMIN_PWD="${ADMIN_PASSWORD:***"
COOKIE_SEC="${COOKIE_SECRET:***"

cat > .dev.vars <<DEVEOF
ADMIN_PASSWORD=***
COOKIE_SECRET=***
DEVEOF

if [ -n "$GPTMAIL_API_KEY" ]; then
  echo "GPTMAIL_API_KEY=$GPTMAIL_API_KEY" >> .dev.vars
fi

# 3. 自动执行 D1 (SQLite) 数据库表结构迁移（包含 0001_init, 0002_tags, 0003_push_state）
echo "正在检查并初始化本地 SQLite 数据库..."
npx wrangler d1 migrations apply outlook-email-db --local --persist-to "$DATA_DIR"

PORT="${PORT:-8787}"
echo "=========================================================="
echo " Outlook 邮件管理面板 (Docker 独立版) 已启动"
echo " 访问端口: $PORT"
echo " 登录密码: $ADMIN_PWD"
echo " 数据目录: $DATA_DIR"
echo "=========================================================="

# 4. 启动后台定时任务调度器（模拟 Cloudflare Cron Triggers）
# 默认每 5 分钟自动唤醒一次，用于自动续期 Token 和 Telegram 邮件轮询推送
(
  sleep 10
  while true; do
    curl -s "http://127.0.0.1:${PORT}/cdn-cgi/local/scheduled" > /dev/null 2>&1 || true
    sleep 300
  done
) &

exec npx wrangler dev --ip 0.0.0.0 --port "$PORT" --persist-to "$DATA_DIR"
