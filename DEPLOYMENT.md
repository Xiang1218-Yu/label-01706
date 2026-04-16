# 部署说明文档

## 目录
1. [项目概述](#项目概述)
2. [环境要求](#环境要求)
3. [快速开始](#快速开始)
4. [环境配置详解](#环境配置详解)
5. [CI/CD 流水线](#cicd-流水线)
6. [生产环境部署](#生产环境部署)
7. [常见问题](#常见问题)

---

## 项目概述

本项目是批量去水印工具的前端用户端，采用工程化架构设计，支持：
- 多环境隔离部署（开发、测试、生产）
- Docker 容器化部署
- CI/CD 自动化构建
- 动态配置管理

---

## 环境要求

### 软件依赖
- Docker >= 20.10.0
- Docker Compose >= 2.0.0
- Make >= 3.81（可选，用于简化命令）

### 硬件要求
- 开发环境：CPU >= 1核，内存 >= 512MB
- 测试环境：CPU >= 1核，内存 >= 512MB
- 生产环境：CPU >= 2核，内存 >= 1GB

---

## 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd <project-directory>
```

### 2. 选择环境并启动

#### 开发环境
```bash
# 使用 Make（推荐）
make dev

# 或使用 docker-compose
cp .env.development .env
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

#### 测试环境
```bash
# 使用 Make
make test

# 或使用 docker-compose
cp .env.testing .env
docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
```

#### 生产环境
```bash
# 使用 Make
make prod

# 或使用 docker-compose
cp .env.production .env
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 3. 访问应用
- 开发环境：http://localhost:8080
- 测试环境：http://localhost:8081
- 生产环境：http://localhost

---

## 环境配置详解

### 环境变量说明

| 变量名 | 说明 | 开发环境 | 测试环境 | 生产环境 |
|--------|------|----------|----------|----------|
| `ENV_NAME` | 环境标识 | development | testing | production |
| `API_BASE_URL` | API 后端地址 | http://localhost:3000 | http://api-test.example.com | https://api.example.com |
| `NGINX_PORT` | Nginx 内部端口 | 80 | 80 | 80 |
| `CACHE_ENABLED` | 静态资源缓存 | false | true | true |
| `GZIP_ENABLED` | Gzip 压缩 | false | true | true |

### 配置文件说明

#### 1. Docker 相关文件
- `Dockerfile`: 多阶段构建配置，支持多环境
- `nginx.conf.template`: Nginx 配置模板，支持环境变量注入
- `docker-entrypoint.sh`: 容器入口脚本，处理配置生成

#### 2. Docker Compose 文件
- `docker-compose.yml`: 基础配置，所有环境共享
- `docker-compose.dev.yml`: 开发环境配置，支持热重载
- `docker-compose.test.yml`: 测试环境配置，模拟生产
- `docker-compose.prod.yml`: 生产环境配置，安全优化

#### 3. 环境变量文件
- `.env.example`: 环境变量示例模板
- `.env.development`: 开发环境配置
- `.env.testing`: 测试环境配置
- `.env.production`: 生产环境配置

---

## CI/CD 流水线

### 流水线概述
项目使用 GitHub Actions 实现 CI/CD 自动化，包含以下阶段：
1. **构建阶段**: 构建 Docker 镜像，推送到 GHCR
2. **安全扫描**: 使用 Trivy 扫描镜像漏洞
3. **部署阶段**: 根据分支自动部署到对应环境

### 触发规则
- `develop` 分支: 自动部署到开发环境
- `test` 分支: 自动部署到测试环境
- `main` 分支: 自动部署到生产环境

### 配置 GitHub Secrets
在 GitHub 仓库设置中添加以下 Secrets：
- `GITHUB_TOKEN`: 自动生成，用于推送镜像

### 配置 GitHub Environments
创建以下环境并配置相应的变量：
1. **development**:
   - `ENV_NAME`: development
   - `DEPLOY_URL`: https://dev.example.com
2. **testing**:
   - `ENV_NAME`: testing
   - `DEPLOY_URL`: https://test.example.com
3. **production**:
   - `ENV_NAME`: production
   - `DEPLOY_URL`: https://example.com

---

## 生产环境部署

### 1. 准备工作
```bash
# 复制生产环境配置
cp .env.production .env

# 修改配置（重要！）
# 编辑 .env 文件，修改 API_BASE_URL 等敏感配置
```

### 2. 启动服务
```bash
# 使用 Make
make prod

# 或手动指定环境
make up ENV=production
```

### 3. 验证部署
```bash
# 查看服务状态
make status ENV=production

# 查看健康检查
make health ENV=production

# 查看日志
make logs ENV=production
```

### 4. 生产环境最佳实践
- 使用 HTTPS（建议配置反向代理或负载均衡器）
- 配置防火墙规则，只开放必要端口
- 配置日志收集和监控告警
- 定期备份数据和配置
- 使用密钥管理服务管理敏感信息
- 配置蓝绿部署或滚动更新策略

---

## Makefile 命令参考

| 命令 | 说明 | 示例 |
|------|------|------|
| `make help` | 显示帮助信息 | `make help` |
| `make up` | 启动服务 | `make up ENV=testing` |
| `make down` | 停止服务 | `make down ENV=production` |
| `make restart` | 重启服务 | `make restart ENV=development` |
| `make logs` | 查看日志 | `make logs ENV=testing` |
| `make shell` | 进入容器 | `make shell ENV=development` |
| `make build` | 构建镜像 | `make build ENV=production` |
| `make status` | 查看状态 | `make status ENV=testing` |
| `make dev` | 快速启动开发环境 | `make dev` |
| `make test` | 快速启动测试环境 | `make test` |
| `make prod` | 快速启动生产环境 | `make prod` |

---

## 常见问题

### Q: 如何修改 API 地址？
A: 修改对应环境的 `.env` 文件中的 `API_BASE_URL` 变量，然后重启服务。

### Q: 如何启用/禁用缓存？
A: 修改 `.env` 文件中的 `CACHE_ENABLED` 变量为 `true` 或 `false`。

### Q: 如何查看容器日志？
A: 使用 `make logs ENV=<环境名>` 或 `docker-compose logs -f`。

### Q: 如何进入容器进行调试？
A: 使用 `make shell ENV=<环境名>`。

### Q: 生产环境如何升级？
A: 
```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新构建镜像
make build ENV=production

# 3. 重启服务
make restart ENV=production
```

### Q: 如何清理 Docker 资源？
A: 
```bash
# 清理特定环境
make clean ENV=development

# 清理所有未使用资源（谨慎）
make prune
```

---

## 技术支持

如有问题，请参考：
1. 本文档的常见问题部分
2. GitHub Issues
3. 项目 README.md
