# 🐳 Docker 独立部署指南 (无需 Cloudflare 账号)

本项目为 [cf-outlook-email](https://github.com/roseforyou/cf-outlook-email) 的 Docker 容器化版本，**纯本地运行，免 Cloudflare 账号，自动初始化并持久化本地 SQLite 数据库**。

---

## 🚀 极速部署 (推荐 Docker Compose)

### 1. 获取项目
```bash
git clone https://github.com/noevers/cf-outlook-email-docker.git
cd cf-outlook-email-docker
```

### 2. 启动服务
```bash
docker compose up -d --build
```

启动后容器会自动：
- 自动生成合规配置与会话密钥
- 自动运行数据库迁移，初始化本地 SQLite 数据库（表结构包含账号表、设置表、标签表等）
- 将数据库文件实时持久化在 `./data` 目录下，容器重启或升级数据不丢失

---

## ⚙️ 环境变量配置

在 `docker-compose.yml` 中支持以下环境变量：

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `ADMIN_PASSWORD` | `admin123` | 面板 Web 登录密码 |
| `COOKIE_SECRET` | 随机生成 32 位字符 | Web 会话加密密钥 |
| `PORT` | `8787` | 容器内监听端口 |
| `DATA_DIR` | `/app/data` | 数据库持久化目录 |
| `GPTMAIL_API_KEY` | *(选填)* | 临时邮箱 API Key |

---

## 📬 批量导入已有的 Client ID 和 Refresh Token

1. 浏览器打开 `http://<你的服务器IP>:8787`。
2. 输入密码（默认 `admin123`，或你自定义的密码）登录。
3. 点击顶栏的 **「批量导入」**：
   - 导入格式：`邮箱----密码----client_id----refresh_token`（没有密码可填任意字符占位）。
   - 或者点击 **「+ 添加账号」** 选择 **手动添加**，直接填入你的 `client_id` 与 `refresh_token`。
   - *(注：若未指定 client_id，系统会自动使用内置的 Mozilla Thunderbird 公开 Client ID)*。
4. 导入后即可直接在左侧列表切换账号，在线查看收件箱、垃圾箱、已删除邮件及自动识别的验证码。
