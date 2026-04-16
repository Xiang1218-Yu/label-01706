# 部署指南

## 工程化方案概述

本项目已实现完整的CI/CD自动化构建部署流程，支持开发、测试、生产三个环境的隔离部署，采用Docker容器化技术，确保环境一致性。

## 目录结构

```
frontend-user/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # CI/CD工作流配置
├── config/
│   ├── dev.env.js             # 开发环境配置
│   ├── test.env.js            # 测试环境配置
│   ├── prod.env.js            # 生产环境配置
│   └── README.md              # 配置说明
├── Dockerfile                 # Docker镜像构建配置
├── .dockerignore              # Docker忽略文件
├── nginx.conf                 # Nginx服务器配置
├── DEPLOYMENT.md              # 部署指南（本文件）
└── ...
```

## 1. CI/CD工作流说明

### 触发条件
| 分支 | 触发动作 | 部署环境 |
|------|----------|----------|
| dev | 代码推送 | 开发环境 |
| test | 代码推送 | 测试环境 |
| main | 代码推送 | 生产环境 |
| - | 手动触发 | 任意环境 |

### 工作流步骤
1. **代码检出**：拉取最新代码
2. **环境识别**：根据分支或手动输入确定部署环境
3. **配置注入**：自动加载对应环境的配置文件
4. **镜像构建**：构建支持多架构的Docker镜像
5. **镜像推送**：推送到容器镜像仓库
6. **自动部署**：SSH连接到对应环境服务器，完成部署

### 需要配置的GitHub Secrets
| 秘钥名称 | 说明 | 示例 |
|----------|------|------|
| DOCKER_REGISTRY_USERNAME | 镜像仓库用户名 | your-username |
| DOCKER_REGISTRY_PASSWORD | 镜像仓库密码 | your-password |
| dev_SERVER_HOST | 开发环境服务器地址 | 192.168.1.100 |
| dev_SERVER_USER | 开发环境服务器用户名 | root |
| dev_SERVER_PASSWORD | 开发环境服务器密码 | your-password |
| dev_SERVER_PORT | 开发环境SSH端口 | 22 |
| dev_PORT | 开发环境服务端口 | 8080 |
| test_SERVER_HOST | 测试环境服务器地址 | 192.168.1.101 |
| test_SERVER_USER | 测试环境服务器用户名 | root |
| test_SERVER_PASSWORD | 测试环境服务器密码 | your-password |
| test_SERVER_PORT | 测试环境SSH端口 | 22 |
| test_PORT | 测试环境服务端口 | 8080 |
| prod_SERVER_HOST | 生产环境服务器地址 | 114.114.114.114 |
| prod_SERVER_USER | 生产环境服务器用户名 | root |
| prod_SERVER_PASSWORD | 生产环境服务器密码 | your-password |
| prod_SERVER_PORT | 生产环境SSH端口 | 22 |
| prod_PORT | 生产环境服务端口 | 80 |

## 2. Docker镜像构建说明

### 本地构建镜像
```bash
# 开发环境
docker build -t frontend-user:dev .

# 测试环境
docker build -t frontend-user:test .

# 生产环境
docker build -t frontend-user:prod .
```

### 运行容器
```bash
# 开发环境
docker run -d --name frontend-user-dev -p 8080:80 frontend-user:dev

# 测试环境
docker run -d --name frontend-user-test -p 8081:80 frontend-user:test

# 生产环境
docker run -d --name frontend-user-prod -p 80:80 frontend-user:prod
```

### 镜像特性
- 多架构支持：同时支持linux/amd64和linux/arm64架构
- 健康检查：内置健康检查，自动监控服务状态
- 多阶段构建：最小化镜像体积，仅约50MB
- 安全配置：使用官方Nginx镜像，无额外依赖

## 3. Nginx配置说明

`nginx.conf`配置特性：
- 支持前端路由（SPA）：所有请求重定向到index.html
- 静态资源缓存：缓存7天，提升加载速度
- Gzip压缩：开启文本资源压缩，减小传输体积
- 安全响应头：默认配置安全相关响应头

## 4. 多环境配置说明

### 环境隔离机制
1. **代码分支隔离**：dev/test/main三个分支分别对应三个环境
2. **配置文件隔离**：每个环境有独立的配置文件，互不影响
3. **部署环境隔离**：三个环境部署在不同服务器，网络隔离
4. **镜像标签隔离**：镜像标签包含环境标识，避免混部

### 配置切换方式
- **自动切换**：CI/CD根据分支自动选择对应配置
- **手动切换**：本地开发时手动复制配置文件到`js/env.js`

## 5. 手动部署步骤

如果需要手动部署，按以下步骤操作：

### 步骤1：准备配置文件
```bash
# 选择环境
ENV=dev # 可选：dev/test/prod

# 复制配置文件
cp config/${ENV}.env.js js/env.js
```

### 步骤2：构建镜像
```bash
docker build -t frontend-user:${ENV} .
```

### 步骤3：运行容器
```bash
docker run -d \
  --name frontend-user-${ENV} \
  --restart always \
  -p 8080:80 \
  frontend-user:${ENV}
```

### 步骤4：验证部署
```bash
# 检查容器状态
docker ps | grep frontend-user

# 访问服务
curl http://localhost:8080
```

## 6. 常见问题排查

### 容器启动失败
```bash
# 查看容器日志
docker logs frontend-user

# 检查Nginx配置
docker exec frontend-user nginx -t
```

### 镜像构建失败
```bash
# 检查Dockerfile语法
docker build --no-cache -t frontend-user:debug .
```

### CI/CD部署失败
1. 检查GitHub Secrets配置是否正确
2. 确认服务器网络是否可以访问镜像仓库
3. 检查服务器端口是否被占用
4. 查看GitHub Actions运行日志，定位具体错误

## 7. 版本回滚

### 方式1：CI/CD回滚
在GitHub Actions中找到之前成功的工作流，点击"Re-run jobs"即可重新部署历史版本。

### 方式2：手动回滚
```bash
# 查看历史镜像
docker images | grep frontend-user

# 回滚到指定版本
docker stop frontend-user
docker rm frontend-user
docker run -d --name frontend-user --restart always -p 80:80 frontend-user:<旧版本标签>
```

## 8. 最佳实践

1. **代码提交规范**：
   - 功能开发提交到dev分支
   - 测试通过后合并到test分支进行测试
   - 测试验收通过后合并到main分支发布到生产
   - 禁止直接向main分支提交代码

2. **配置管理**：
   - 配置文件变更需要提交到代码库
   - 敏感信息不要提交到代码库，通过Secrets管理
   - 不同环境的API地址等配置保持独立

3. **部署规范**：
   - 生产环境部署选择业务低峰期
   - 部署前备份当前版本镜像
   - 部署后进行冒烟测试，验证功能正常
