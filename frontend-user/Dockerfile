# ============================================
# 批量去水印工具 - 前端用户端 Dockerfile
# 功能：支持多环境构建的容器化配置
# 构建参数：
#   - BUILD_ENV: 构建环境 (development/test/production)
#   - BUILDPLATFORM: 构建平台架构
# ============================================

# ============================================
# 第一阶段：构建阶段
# 作用：统一处理静态资源复制和环境配置
# 基础镜像选用官方 nginx alpine，轻量级且支持多架构
# ============================================
FROM --platform=$BUILDPLATFORM nginx:1.25-alpine AS builder

# 构建参数：环境类型，默认为 production
ARG BUILD_ENV=production
ENV BUILD_ENV=${BUILD_ENV}

# 设置工作目录
WORKDIR /usr/share/nginx/html

# ============================================
# 复制静态资源
# 按目录分层复制，利用Docker缓存机制
# ============================================
COPY index.html ./
COPY css/ ./css/
COPY js/ ./js/
COPY libs/ ./libs/

# ============================================
# 根据构建环境选择nginx配置文件
# 支持三种环境：开发、测试、生产
# ============================================
COPY nginx/nginx.${BUILD_ENV}.conf /etc/nginx/conf.d/default.conf

# ============================================
# 第二阶段：最终运行镜像
# 作用：只包含运行所需的最小文件，减小镜像体积
# ============================================
FROM nginx:1.25-alpine

# 维护者信息
LABEL maintainer="dev@example.com"
LABEL description="Watermark Remover Frontend"
LABEL version="1.0.0"

# 运行时环境变量
ENV NODE_ENV=production
ENV NGINX_PORT=80

# 从构建阶段复制静态资源和配置
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# ============================================
# 健康检查配置
# 定期检查容器健康状态
# ============================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# 暴露端口
EXPOSE ${NGINX_PORT}

# 使用非root用户运行（安全最佳实践）
RUN apk add --no-cache shadow && \
    usermod -u 1001 nginx && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

# 启动命令
CMD ["nginx", "-g", "daemon off;"]
