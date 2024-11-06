#!/bin/bash

# 检查系统是否为root用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 权限运行此脚本。"
    exit 1
fi

# 更新系统并安装必要的软件包
echo "更新系统并安装 Docker 和 Docker Compose..."
apt update -y && apt upgrade -y
apt install -y curl git

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | bash
else
    echo "Docker 已安装。"
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose 已安装。"
fi

# 创建 Nginx Proxy Manager 目录和 docker-compose 文件
echo "设置 Nginx Proxy Manager 目录和文件..."
mkdir -p /opt/nginx-proxy-manager
cd /opt/nginx-proxy-manager

# 创建 docker-compose.yml 文件
cat > docker-compose.yml <<EOF
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# 启动 Docker 容器
echo "启动 Nginx Proxy Manager..."
docker-compose up -d

# 检查服务是否启动成功
if [ "$(docker ps | grep jc21/nginx-proxy-manager)" ]; then
    echo "Nginx Proxy Manager 安装成功！"
    echo "请访问 http://<服务器IP>:81 使用 Nginx Proxy Manager，默认用户名和密码为 admin@example.com / changeme。"
else
    echo "安装失败，请检查日志。"
fi
