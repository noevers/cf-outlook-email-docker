FROM node:22-slim

LABEL maintainer="noevers"
LABEL description="Dockerized Outlook Email Manager (cf-outlook-email)"

WORKDIR /app

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends     curl     ca-certificates   && rm -rf /var/lib/apt/lists/*

# 复制依赖配置并预装
COPY package*.json pnpm-lock.yaml* ./
RUN npm install --legacy-peer-deps

# 复制项目代码与入口脚本
COPY . .
RUN chmod +x /app/entrypoint.sh

EXPOSE 8787

VOLUME ["/app/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
