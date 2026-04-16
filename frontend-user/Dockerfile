# Dockerfile 前端用户端镜像构建配置
# 支持多架构构建(linux/amd64, linux/arm64)
# 支持多环境配置注入
# 采用多阶段构建，减小最终镜像体积

# ==============================================
# 构建阶段：准备静态资源和配置
# ==============================================
FROM --platform=$BUILDPLATFORM nginx:1.25-alpine AS builder

# 工作目录
WORKDIR /usr/share/nginx/html

# 复制静态资源文件
COPY index.html ./
COPY css/ ./css/
COPY js/ ./js/
COPY libs/ ./libs/

# 复制Nginx配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# ==============================================
# 最终运行阶段：最小化运行镜像
# ==============================================
FROM nginx:1.25-alpine

# 维护者信息
LABEL maintainer="dev@example.com"
LABEL description="批量去水印工具前端用户端"
LABEL version="1.0.0"

# 从构建阶段复制资源
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# 暴露服务端口
EXPOSE 80

# 健康检查配置
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# 启动Nginx服务
CMD ["nginx", "-g", "daemon off;"]
