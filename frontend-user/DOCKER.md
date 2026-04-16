# Docker 多环境配置说明

## 概述

本项目已实现完整的Docker多环境部署方案，支持开发、测试、生产三个环境的完全隔离配置，所有环境配置独立管理，部署流程统一。

## 目录结构

```
frontend-user/
├── .env.dev                  # 开发环境Docker配置
├── .env.test                 # 测试环境Docker配置
├── .env.prod                 # 生产环境Docker配置
├── docker-compose.yml        # Docker Compose配置（支持多环境）
├── deploy.sh                 # 一键部署脚本
├── Dockerfile                # 镜像构建文件（支持多环境参数）
└── ...
```

## 配置文件说明

### 1. 环境变量文件（.env.*）

每个环境都有独立的配置文件，包含该环境的所有定制化配置：

#### 公共配置项
| 配置项 | 说明 | 示例值 |
|--------|------|--------|
| CONTAINER_NAME | 容器名称 | frontend-user-dev |
| PORT | 服务暴露端口 | 8080 |
| NETWORK_NAME | Docker网络名称 | dev-network |
| IMAGE_NAME | 镜像名称 | frontend-user |
| IMAGE_TAG | 镜像标签 | dev-latest |
| ENV | 环境标识 | dev/test/prod |
| DEBUG | 是否开启调试模式 | true/false |
| LOG_LEVEL | 日志级别 | debug/info/warn/error |
| CPU_LIMIT | CPU资源限制 | 0.5/1.0/2.0 |
| MEMORY_LIMIT | 内存资源限制 | 512M/1G/2G |

#### 生产环境特有配置
| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| HEALTHCHECK_INTERVAL | 健康检查间隔 | 10s |
| HEALTHCHECK_RETRIES | 健康检查重试次数 | 5 |
| RESTART_POLICY | 容器重启策略 | always |
| LOG_MAX_SIZE | 日志文件最大大小 | 100m |
| LOG_MAX_FILE | 日志文件保留数量 | 3 |

### 2. docker-compose.yml

通用配置模板，根据加载的环境变量自动适配不同环境：
- 自动加载对应环境的配置文件
- 自动注入环境变量到容器
- 开发环境自动挂载本地文件支持热重载
- 生产环境自动配置资源限制和日志策略
- 每个环境自动创建独立的Docker网络

### 3. deploy.sh 部署脚本

提供一键部署能力，简化操作流程：
- 自动检查环境配置文件存在性
- 自动加载对应环境的变量
- 支持常用操作：启动、停止、重启、查看日志、构建、进入容器等
- 开发环境自动启用热重载

## 使用方式

### 方式1：使用部署脚本（推荐）

```bash
# 启动开发环境
./deploy.sh dev up

# 启动测试环境
./deploy.sh test up

# 启动生产环境
./deploy.sh prod up

# 查看环境状态
./deploy.sh dev status

# 查看日志
./deploy.sh dev logs

# 重启环境
./deploy.sh dev restart

# 停止环境
./deploy.sh dev down

# 进入容器
./deploy.sh dev exec
```

### 方式2：直接使用docker-compose命令

```bash
# 开发环境
docker-compose --env-file .env.dev up -d --build

# 测试环境
docker-compose --env-file .env.test up -d --build

# 生产环境
docker-compose --env-file .env.prod up -d --build

# 查看日志
docker-compose --env-file .env.dev logs -f

# 停止服务
docker-compose --env-file .env.dev down
```

## 环境特性

### 开发环境
- 端口：8080
- 支持代码热重载，修改本地文件立即生效
- 开启调试模式，日志级别为debug
- 资源限制：0.5核CPU，512MB内存
- 独立网络：dev-network

### 测试环境
- 端口：8081
- 不支持热重载，使用镜像内置代码
- 开启调试模式，日志级别为info
- 资源限制：1核CPU，1GB内存
- 独立网络：test-network

### 生产环境
- 端口：80
- 不支持热重载，镜像打包时固化代码
- 关闭调试模式，日志级别为warn
- 资源限制：2核CPU，2GB内存
- 独立网络：prod-network
- 更严格的健康检查策略
- 日志自动轮转，避免磁盘占满
- 蓝绿部署支持，无停机发布

## 构建参数说明

Dockerfile支持以下构建参数，可在构建时传入：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| ENV | 环境标识 | prod |
| VERSION | 应用版本 | latest |
| BUILD_DATE | 构建时间 | 当前时间 |

构建时传入参数示例：
```bash
docker build --build-arg ENV=test --build-arg VERSION=v1.0.0 --build-arg BUILD_DATE=$(date -Iseconds) -t frontend-user:test .
```

## 最佳实践

1. **配置管理**
   - 不要直接修改.env.*文件中的默认配置，如需定制请创建.local后缀的本地配置文件
   - 敏感信息不要提交到代码库，使用环境变量或秘钥管理系统
   - 不同环境的配置保持独立，避免混用

2. **开发流程**
   - 开发阶段使用`./deploy.sh dev up`启动开发环境，支持热重载
   - 功能开发完成后推送到dev分支，触发CI/CD自动部署到开发环境
   - 测试阶段使用测试环境进行验证，确认无误后合并到main分支

3. **生产部署**
   - 生产环境使用蓝绿部署，避免停机
   - 部署前备份当前镜像，便于快速回滚
   - 部署后进行冒烟测试，验证服务正常运行

4. **故障排查**
   - 使用`./deploy.sh [env] logs`查看日志
   - 使用`./deploy.sh [env] exec`进入容器排查问题
   - 使用`docker inspect [container_name]`查看容器详细信息

## 常见问题

### Q: 开发环境修改代码后页面不更新？
A: 确认使用的是开发环境（./deploy.sh dev up），开发环境会自动挂载本地文件，修改后刷新页面即可生效。如果还是不生效，请检查浏览器缓存。

### Q: 如何修改服务端口？
A: 修改对应环境的.env文件中的`PORT`配置项，重启服务即可。

### Q: 如何自定义Nginx配置？
A: 修改项目根目录下的`nginx.conf`文件，重新构建镜像即可生效。不同环境可以使用不同的Nginx配置，在docker-compose.yml中根据环境变量挂载对应配置文件。

### Q: 如何添加新的环境变量？
A: 在对应的.env文件中添加变量，然后在docker-compose.yml的`environment`部分添加对应的映射，需要在代码中使用的话还需要在配置注入逻辑中处理。

### Q: 如何限制容器资源使用？
A: 修改对应环境.env文件中的`CPU_LIMIT`和`MEMORY_LIMIT`配置项，重启服务生效。
