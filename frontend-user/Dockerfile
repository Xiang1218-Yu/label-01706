# 批量去水印工具 - 前端用户端 Docker 镜像构建文件
# 支持多环境构建：开发/测试/生产环境
# 基础镜像选用官方 nginx alpine，支持 linux/amd64 和 linux/arm64 多架构
ARG BUILDPLATFORM
ARG NODE_ENV=production
FROM --platform=$BUILDPLATFORM nginx:1.25-alpine AS builder

# 环境变量参数，构建时可传入不同环境配置
ARG API_BASE_URL
ARG APP_ENV=production

# 复制静态资源到 nginx 默认目录
COPY index.html /usr/share/nginx/html/
COPY css/ /usr/share/nginx/html/css/
COPY js/ /usr/share/nginx/html/js/
COPY libs/ /usr/share/nginx/html/libs/

# 注入环境变量到前端配置文件
RUN if [ -n "$API_BASE_URL" ]; then \
      sed -i "s|{{API_BASE_URL}}|$API_BASE_URL|g" /usr/share/nginx/html/js/app.js; \
    fi && \
    echo "window.APP_ENV = '$APP_ENV';" > /usr/share/nginx/html/js/env.js

# 自定义 nginx 配置，根据环境选择不同配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx.${APP_ENV}.conf /etc/nginx/conf.d/env.conf 2>/dev/null || true

# 最终运行镜像
FROM nginx:1.25-alpine

# 安装必要工具用于健康检查
RUN apk add --no-cache curl

COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# 健康检查配置
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
