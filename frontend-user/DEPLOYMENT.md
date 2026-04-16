# ============================================
# 前端工程化部署指南
# ============================================

## 目录
1. [项目概述](#项目概述)
2. [环境隔离说明](#环境隔离说明)
3. [Docker容器化部署](#docker容器化部署)
4. [CI/CD自动化构建](#cicd自动化构建)
5. [快速开始](#快速开始)
6. [配置文件说明](#配置文件说明)

---

## 项目概述

本项目已完成工程化改造，实现了：
- ✅ 多环境隔离部署（开发/测试/生产）
- ✅ Docker容器化部署
- ✅ CI/CD自动化构建和部署
- ✅ 完善的配置文件和代码注释

---

## 环境隔离说明

### 环境划分

| 环境 | 分支 | 端口 | 访问地址 | 特点 |
|------|------|------|----------|------|
| 开发环境 | develop | 8081 | http://localhost:8081 | 热更新、详细日志、无缓存 |
| 测试环境 | test | 8082 | http://test.example.com | 模拟生产、适中缓存、完整日志 |
| 生产环境 | main | 80 | https://example.com | 高性能、长期缓存、严格安全 |

### 环境切换方式

#### 方式一：使用docker-compose组合配置
```bash
# 开发环境
docker-compose -f docker-compose.base.yml -f docker-compose.development.yml up -d

# 测试环境
docker-compose -f docker-compose.base.yml -f docker-compose.test.yml up -d

# 生产环境
docker-compose -f docker-compose.base.yml -f docker-compose.production.yml up -d
```

#### 方式二：使用环境变量
```bash
# 复制环境变量模板
cp .env.example .env.development
cp .env.example .env.test
cp .env.example .env.production

# 修改对应环境的配置后启动
docker-compose --env-file .env.development -f docker-compose.development.yml up -d
```

---

## Docker容器化部署

### Dockerfile多阶段构建

本项目采用多阶段构建策略：
1. **构建阶段**：复制静态资源，根据环境选择配置文件
2. **运行阶段**：只包含运行所需的最小文件，减小镜像体积

### 构建参数说明

| 参数 | 说明 | 默认值 | 可选值 |
|------|------|--------|--------|
| BUILD_ENV | 构建环境 | production | development/test/production |
| BUILDPLATFORM | 构建平台 | 自动检测 | linux/amd64/linux/arm64 |

### 构建命令示例

```bash
# 构建开发环境镜像
docker build --build-arg BUILD_ENV=development -t frontend:dev .

# 构建测试环境镜像
docker build --build-arg BUILD_ENV=test -t frontend:test .

# 构建生产环境镜像
docker build --build-arg BUILD_ENV=production -t frontend:prod .
```

### 安全特性

- ✅ 使用非root用户运行容器
- ✅ 健康检查配置
- ✅ 生产环境只读文件系统
- ✅ 资源限制配置

---

## CI/CD自动化构建

### 工作流触发条件

| 事件 | 触发分支 | 执行动作 |
|------|----------|----------|
| 代码推送 | develop | 构建+部署到开发环境 |
| 代码推送 | test | 构建+部署到测试环境 |
| 代码推送 | main | 构建+部署到生产环境 |
| Pull Request | 所有分支 | 代码检查+构建测试 |
| 手动触发 | 任意 | 可选择部署环境 |

### 工作流阶段

1. **代码检查阶段**：验证HTML/CSS/JS文件语法
2. **构建阶段**：构建多架构Docker镜像并推送
3. **部署阶段**：部署到对应环境

### 手动触发部署

在GitHub Actions页面可以手动触发部署：
1. 进入Actions标签页
2. 选择"CI/CD Pipeline"工作流
3. 点击"Run workflow"
4. 选择目标环境
5. 点击"Run workflow"确认

---

## 快速开始

### 本地开发环境启动

```bash
# 1. 进入项目目录
cd /path/to/project

# 2. 启动开发环境（支持热更新）
docker-compose -f docker-compose.base.yml -f docker-compose.development.yml up

# 3. 访问应用
open http://localhost:8081
```

### 测试环境部署

```bash
# 1. 启动测试环境
docker-compose -f docker-compose.base.yml -f docker-compose.test.yml up -d

# 2. 查看日志
docker logs -f watermark-remover-frontend-test

# 3. 访问应用
open http://localhost:8082
```

### 生产环境部署

```bash
# 1. 启动生产环境
docker-compose -f docker-compose.base.yml -f docker-compose.production.yml up -d

# 2. 查看容器状态
docker ps

# 3. 查看健康检查状态
docker inspect --format='{{.State.Health.Status}}' watermark-remover-frontend-prod
```

---

## 配置文件说明

### 目录结构

```
frontend-user/
├── Dockerfile              # Docker镜像构建文件
├── nginx/
│   ├── nginx.development.conf    # 开发环境Nginx配置
│   ├── nginx.test.conf           # 测试环境Nginx配置
│   └── nginx.production.conf     # 生产环境Nginx配置
└── DEPLOYMENT.md           # 本部署指南

项目根目录/
├── docker-compose.base.yml          # Docker Compose基础配置
├── docker-compose.development.yml   # 开发环境配置
├── docker-compose.test.yml          # 测试环境配置
├── docker-compose.production.yml    # 生产环境配置
├── .env.example                     # 环境变量示例
└── .github/
    └── workflows/
        └── ci-cd.yml               # CI/CD工作流配置
```

### 各配置文件详细说明

#### 1. Dockerfile
- **位置**: `frontend-user/Dockerfile`
- **功能**: 定义Docker镜像构建流程
- **关键点**:
  - 多阶段构建减小镜像体积
  - 支持根据BUILD_ENV选择配置
  - 包含健康检查配置
  - 使用非root用户运行

#### 2. Nginx配置文件
- **位置**: `frontend-user/nginx/`
- **开发环境**:
  - 关闭缓存便于调试
  - 开启详细日志
  - 允许CORS跨域
- **测试环境**:
  - 适中的缓存策略
  - 保留完整日志
  - 限制跨域域名
- **生产环境**:
  - 高性能优化配置
  - 严格的安全策略
  - 长期缓存提升性能

#### 3. Docker Compose配置
- **基础配置** (`docker-compose.base.yml`): 所有环境通用配置
- **开发环境** (`docker-compose.development.yml`): 支持热更新的卷挂载
- **测试环境** (`docker-compose.test.yml`): 资源限制配置
- **生产环境** (`docker-compose.production.yml`): 安全加固配置

#### 4. CI/CD工作流
- **位置**: `.github/workflows/ci-cd.yml`
- **功能**: 自动化构建和部署
- **支持**: 多架构镜像构建、自动部署、手动触发

---

## 常用命令

### 容器管理
```bash
# 查看容器状态
docker ps

# 查看容器日志
docker logs -f <container_name>

# 进入容器
docker exec -it <container_name> sh

# 重启容器
docker restart <container_name>

# 停止容器
docker stop <container_name>
```

### Docker Compose管理
```bash
# 启动服务
docker-compose -f <配置文件> up -d

# 停止服务
docker-compose -f <配置文件> down

# 重新构建并启动
docker-compose -f <配置文件> up -d --build

# 查看服务状态
docker-compose -f <配置文件> ps
```

### 镜像管理
```bash
# 查看镜像列表
docker images

# 删除镜像
docker rmi <image_id>

# 清理无用镜像
docker image prune
```

---

## 故障排查

### 容器无法启动
1. 检查端口是否被占用: `lsof -i :8081`
2. 查看容器日志: `docker logs <container_name>`
3. 检查配置文件语法

### 健康检查失败
1. 检查容器内部服务: `docker exec <container_name> wget http://localhost`
2. 检查Nginx配置: `docker exec <container_name> nginx -t`

### 访问异常
1. 检查防火墙设置
2. 验证端口映射配置
3. 查看Nginx错误日志
