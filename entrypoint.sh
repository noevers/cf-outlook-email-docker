#!/bin/sh
set -e

DATA_DIR="${DATA_DIR:-/app/data}"
mkdir -p "$DATA_DIR"

# 1. 确保 wrangler.toml 存在且 database_id 格式有效
if [ ! -f wrangler.toml ]; then
  echo "正在自动从 wrangler.toml.example 生成 wrangler.toml..."
  sed 's/database_id = "REPLACE_WITH_YOUR_DATABASE_ID"/database_id = "11111111-2222-3333-4444-555555555555"/' wrangler.toml.example > wrangler.toml
fi

# 2. 注入登录密码与密钥配置
ADMIN_PWD="${ADMIN_PASSWORD:***"
COOKIE_SEC="${COOKIE_SECRET:***"

cat > .dev.vars <<DEVEOF
ADMIN_PASSWORD=***
COOKIE_SECRET=***
DEVEOF

if [ -n "$GPTMAIL_API_KEY" ]; then
  echo "GPTMAIL_API_KEY=$GPTMAIL_API_KEY" >> .dev.vars
fi

# 3. 自动执行 D1 (SQLite) 数据库表结构迁移并持久化
echo "正在检查并初始化本地 SQLite 数据库..."
npx wrangler d1 migrations apply outlook-email-db --local --persist-to "$DATA_DIR"

PORT="${PORT:-8787}"
echo "=========================================================="
echo " Outlook 邮件管理面板已启动"
echo " 访问端口: $PORT"
echo " 登录密码: $ADMIN_PWD"
echo " 数据目录: $DATA_DIR"
echo "=========================================================="

exec npx wrangler dev --ip 0.0.0.0 --port "$PORT" --persist-to "$DATA_DIR"
