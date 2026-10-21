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
if [ -z "$ADMIN_PASSWORD" ]; then
  ADMIN_PWD="admin123"
else
  ADMIN_PWD="$ADMIN_PASSWORD"
fi

if [ -z "$COOKIE_SECRET" ]; then
  COOKIE_SEC="aK3mX9pQ2wE8rT6yU1iO4sD7fG0hJ5laK3mX9pQ"
else
  COOKIE_SEC="$COOKIE_SECRET"
fi

cat > .dev.vars <<EOF
ADMIN_PASSWORD=$ADMIN_PWD
COOKIE_SECRET=$COOKIE_SEC
EOF

if [ -n "$GPTMAIL_API_KEY" ]; then
  echo "GPTMAIL_API_KEY=$GPTMAIL_API_KEY" >> .dev.vars
fi

# 3. 自动执行 D1 (SQLite) 数据库表结构迁移
echo "正在检查并初始化本地 SQLite 数据库..."
npx wrangler d1 migrations apply outlook-email-db --local --persist-to "$DATA_DIR"

if [ -z "$PORT" ]; then
  PORT="8787"
fi

echo "=========================================================="
echo " Outlook 邮件管理面板 (Docker 独立版) 已启动"
echo " 访问端口: $PORT"
echo " 登录密码: $ADMIN_PWD"
echo " 数据目录: $DATA_DIR"
echo "=========================================================="

# 4. 后台定时触发器
(
  sleep 10
  while true; do
    curl -s "http://127.0.0.1:${PORT}/cdn-cgi/local/scheduled" > /dev/null 2>&1 || true
    sleep 300
  done
) &

exec npx wrangler dev --ip 0.0.0.0 --port "$PORT" --persist-to "$DATA_DIR"
