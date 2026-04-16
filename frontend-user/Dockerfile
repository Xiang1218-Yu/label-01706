# Dockerfile 前端用户端镜像构建配置
# 支持多架构构建(linux/amd64, linux/arm64)
# 支持多环境配置注入
# 支持构建时环境变量传递
# 采用多阶段构建，减小最终镜像体积

# 构建参数，可在构建时传入
ARG ENV=prod
ARG VERSION=latest
ARG BUILD_DATE

# ==============================================
# 构建阶段：准备静态资源和配置
# ==============================================
FROM --platform=$BUILDPLATFORM nginx:1.25-alpine AS builder

# 传递构建参数
ARG ENV
ARG VERSION
ARG BUILD_DATE

# 工作目录
WORKDIR /usr/share/nginx/html

# 复制静态资源文件
COPY index.html ./
COPY css/ ./css/
COPY js/ ./js/
COPY libs/ ./libs/

# 复制Nginx配置文件，根据环境选择不同配置（如果需要）
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 构建时注入环境信息到页面
RUN sed -i "s/<!-- BUILD_INFO -->/<meta name=\"build-version\" content=\"${VERSION}\">\n    <meta name=\"build-env\" content=\"${ENV}\">\n    <meta name=\"build-date\" content=\"${BUILD_DATE}\">/" index.html

# ==============================================
# 最终运行阶段：最小化运行镜像
# ==============================================
FROM nginx:1.25-alpine

# 传递构建参数
ARG ENV
ARG VERSION
ARG BUILD_DATE

# 环境变量，运行时可覆盖
ENV ENV=${ENV}
ENV VERSION=${VERSION}
ENV BUILD_DATE=${BUILD_DATE}
ENV TZ=Asia/Shanghai

# 维护者信息
LABEL maintainer="dev@example.com"
LABEL description="批量去水印工具前端用户端"
LABEL version="${VERSION}"
LABEL environment="${ENV}"
LABEL build.date="${BUILD_DATE}"

# 安装必要工具（健康检查需要curl）
RUN apk add --no-cache curl tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

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
