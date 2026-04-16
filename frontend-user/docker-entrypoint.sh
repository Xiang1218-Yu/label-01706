#!/bin/sh
# ============================================
# Docker 容器入口点脚本
# 功能：
#   1. 处理环境变量
#   2. 生成 Nginx 配置
#   3. 启动 Nginx
# ============================================

set -e

# 输出环境信息
echo "=========================================="
echo "Starting frontend-user container"
echo "Environment: ${ENV_NAME}"
echo "Nginx Port: ${NGINX_PORT}"
echo "API Base URL: ${API_BASE_URL}"
echo "Cache Enabled: ${CACHE_ENABLED}"
echo "Gzip Enabled: ${GZIP_ENABLED}"
echo "=========================================="

# 使用 envsubst 替换环境变量到 Nginx 配置
envsubst '${NGINX_PORT},${ENV_NAME},${API_BASE_URL},${CACHE_ENABLED},${GZIP_ENABLED}' \
    < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

# 输出生成的配置（调试用）
echo "Generated Nginx configuration:"
cat /etc/nginx/conf.d/default.conf
echo "=========================================="

# 测试 Nginx 配置
echo "Testing Nginx configuration..."
nginx -t
echo "=========================================="

# 执行传入的命令（默认为启动 Nginx）
exec "$@"
