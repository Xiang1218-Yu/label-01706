# 前端用户端工程化部署指南

## 项目概述
本项目已实现完整的工程化配置，支持：
- 多环境隔离部署（开发/测试/生产）
- Docker容器化构建
- GitHub Actions CI/CD自动化构建部署
- 环境配置自动注入

## 目录结构说明
```
frontend-user/
├── .env.development      # 开发环境变量配置
├── .env.test             # 测试环境变量配置
├── .env.production       # 生产环境变量配置
├── .github/
│   └── workflows/
│       └── ci-cd.yml     # CI/CD自动化工作流配置
├── Dockerfile            # 多环境Docker镜像构建文件
├── nginx.conf            # Nginx基础配置（所有环境通用）
├── nginx.development.conf # 开发环境Nginx差异化配置
├── nginx.test.conf       # 测试环境Nginx差异化配置
├── nginx.production.conf # 生产环境Nginx差异化配置
├── docker-compose.yml    # 多环境Docker Compose编排配置
├── index.html            # 入口HTML文件
├── css/                  # 样式文件目录
├── js/                   # JavaScript文件目录
└── libs/                 # 第三方库目录
```

## 多环境配置说明

### 1. 环境区分
- **开发环境**：本地开发调试使用，支持热更新，禁用缓存，允许跨域
- **测试环境**：测试/预发部署使用，完整功能测试，测试环境API
- **生产环境**：正式上线使用，性能优化，安全加固，生产环境API

### 2. 环境变量配置
每个环境对应独立的`.env.{env}`配置文件：
- `APP_ENV`: 环境标识
- `API_BASE_URL`: 后端API接口地址
- `DEBUG`: 是否开启调试模式
- `PORT`: 服务监听端口

## Docker构建指南

### 基础构建命令
```bash
# 默认构建生产环境镜像
docker build -t frontend-user:latest .

# 构建开发环境镜像
docker build --build-arg APP_ENV=development --build-arg API_BASE_URL=http://localhost:3000/api -t frontend-user:dev .

# 构建测试环境镜像
docker build --build-arg APP_ENV=test --build-arg API_BASE_URL=https://test-api.example.com/api -t frontend-user:test .

# 构建生产环境镜像
docker build --build-arg APP_ENV=production --build-arg API_BASE_URL=https://api.example.com/api -t frontend-user:prod .
```

### 运行容器
```bash
# 运行开发环境
docker run -d -p 8080:80 --name frontend-dev frontend-user:dev

# 运行测试环境
docker run -d -p 8081:80 --name frontend-test frontend-user:test

# 运行生产环境
docker run -d -p 80:80 --name frontend-prod --restart always frontend-user:prod
```

## Docker Compose使用说明

### 一键启动对应环境
```bash
# 启动开发环境（支持热更新）
docker-compose up frontend-dev

# 启动测试环境
docker-compose up frontend-test

# 启动生产环境
docker-compose up frontend-prod

# 后台启动
docker-compose up -d frontend-dev
```

### 常用命令
```bash
# 停止服务
docker-compose down frontend-dev

# 重新构建并启动
docker-compose up -d --build frontend-dev

# 查看日志
docker-compose logs -f frontend-dev
```

## CI/CD流程说明

### 工作流触发规则
| 分支       | 触发环境   | 部署目标         |
|------------|------------|------------------|
| `develop`  | 开发环境   | 开发服务器       |
| `test`     | 测试环境   | 测试服务器       |
| `main`     | 生产环境   | 生产服务器       |

### 流程步骤
1. **代码检查**：自动校验HTML/CSS/JS语法规范性
2. **镜像构建**：多架构构建（支持AMD64/ARM64），自动注入对应环境配置
3. **镜像推送**：自动推送到容器镜像仓库
4. **自动部署**：SSH连接到对应环境服务器，完成自动化部署

### 需要配置的GitHub Secrets
| Secret名称                | 说明                          |
|---------------------------|-------------------------------|
| `DEVELOPMENT_API_URL`     | 开发环境API地址               |
| `TEST_API_URL`            | 测试环境API地址               |
| `PRODUCTION_API_URL`      | 生产环境API地址               |
| `SSH_HOST`                | 服务器IP地址                  |
| `SSH_USERNAME`            | 服务器登录用户名              |
| `SSH_PRIVATE_KEY`         | 服务器SSH私钥                 |
| `PORT`                    | 服务监听端口（对应不同环境）  |

## 部署注意事项

1. **敏感信息**：生产环境敏感信息不要提交到代码仓库，通过CI/CD环境变量注入
2. **域名配置**：根据实际域名修改`nginx.{env}.conf`中的域名限制规则
3. **API代理**：根据实际后端接口地址修改Nginx配置中的代理规则
4. **资源限制**：生产环境建议配置合理的CPU/内存资源限制
5. **健康检查**：容器内置健康检查接口`/health`，可用于监控告警
6. **缓存策略**：生产环境静态资源默认缓存365天，版本更新时建议添加资源hash

## 健康检查
容器内置健康检查功能，可通过以下方式检查服务状态：
```bash
# 检查容器健康状态
docker inspect --format='{{.State.Health.Status}}' frontend-user

# 访问健康检查接口
curl http://localhost/health
# 正常返回 "OK"
```
