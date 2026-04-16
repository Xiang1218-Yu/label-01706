# ============================================
# 批量去水印工具 - 前端用户端 Dockerfile
# 支持多阶段构建、多平台架构、多环境配置
# ============================================

# 构建参数 - 可在构建时覆盖
ARG BUILDPLATFORM=linux/amd64
ARG NODE_VERSION=20-alpine
ARG NGINX_VERSION=1.25-alpine

# ============================================
# 第一阶段：构建阶段（用于未来扩展，如TypeScript编译、CSS预处理等）
# ============================================
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION} AS builder

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 这里可以添加构建命令，例如：
# - npm install
# - npm run build
# 目前是纯静态项目，直接复制文件即可

# ============================================
# 第二阶段：Nginx 运行阶段
# ============================================
FROM --platform=$BUILDPLATFORM nginx:${NGINX_VERSION} AS production

# 环境变量 - 运行时可配置
ENV ENV_NAME=production
ENV API_BASE_URL=http://localhost:3000
ENV NGINX_PORT=80
ENV CACHE_ENABLED=true
ENV GZIP_ENABLED=true

# 安装必要工具（用于健康检查）
RUN apk add --no-cache curl

# 复制静态资源到 nginx 默认目录
COPY --from=builder /app/index.html /usr/share/nginx/html/
COPY --from=builder /app/css/ /usr/share/nginx/html/css/
COPY --from=builder /app/js/ /usr/share/nginx/html/js/
COPY --from=builder /app/libs/ /usr/share/nginx/html/libs/

# 复制 Nginx 配置模板
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# 复制环境变量注入脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 暴露端口
EXPOSE ${NGINX_PORT}

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${NGINX_PORT}/ || exit 1

# 入口点脚本
ENTRYPOINT ["/docker-entrypoint.sh"]

# 默认命令
CMD ["nginx", "-g", "daemon off;"]

# ============================================
# 开发环境阶段（带调试信息）
# ============================================
FROM production AS development

ENV ENV_NAME=development
ENV CACHE_ENABLED=false
ENV GZIP_ENABLED=false

# 安装更多调试工具
RUN apk add --no-cache vim nano

# 开发环境可以添加更多调试配置
# 例如：开启 Nginx 调试日志等

# ============================================
# 测试环境阶段
# ============================================
FROM production AS testing

ENV ENV_NAME=testing
