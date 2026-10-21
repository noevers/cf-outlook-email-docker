FROM node:20-alpine

LABEL maintainer="noevers"
LABEL description="Dockerized Outlook Email Manager (cf-outlook-email)"

WORKDIR /app

# 安装基础依赖
RUN apk add --no-cache curl ca-certificates

# 复制依赖配置并预装
COPY package*.json pnpm-lock.yaml* ./
RUN npm install --legacy-peer-deps

# 复制项目代码与入口脚本
COPY . .
RUN chmod +x /app/entrypoint.sh

EXPOSE 8787

VOLUME ["/app/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
