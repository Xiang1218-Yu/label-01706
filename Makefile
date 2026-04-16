# ============================================
# Makefile - 项目构建和部署自动化工具
# 使用方式: make <目标>
# 示例: make dev / make test / make prod
# ============================================

# ============================================
# 变量定义
# ============================================

# Docker Compose 配置文件
COMPOSE_BASE = docker-compose.base.yml
COMPOSE_DEV = docker-compose.development.yml
COMPOSE_TEST = docker-compose.test.yml
COMPOSE_PROD = docker-compose.production.yml

# 容器名称
CONTAINER_DEV = watermark-remover-frontend-dev
CONTAINER_TEST = watermark-remover-frontend-test
CONTAINER_PROD = watermark-remover-frontend-prod

# 默认目标
.DEFAULT_GOAL := help

# ============================================
# 帮助信息
# ============================================
.PHONY: help
help: ## 显示帮助信息
	@echo "========================================"
	@echo "批量去水印工具 - 前端工程化部署"
	@echo "========================================"
	@echo ""
	@echo "可用命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ============================================
# 开发环境命令
# ============================================
.PHONY: dev
dev: ## 启动开发环境（前台运行）
	@echo "🚀 启动开发环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) up

.PHONY: dev-up
dev-up: ## 启动开发环境（后台运行）
	@echo "🚀 启动开发环境（后台）..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) up -d
	@echo "✅ 开发环境已启动，访问地址: http://localhost:8081"

.PHONY: dev-down
dev-down: ## 停止开发环境
	@echo "⏹️  停止开发环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) down

.PHONY: dev-logs
dev-logs: ## 查看开发环境日志
	@echo "📋 查看开发环境日志..."
	docker logs -f $(CONTAINER_DEV)

.PHONY: dev-shell
dev-shell: ## 进入开发环境容器
	@echo "🐚 进入开发环境容器..."
	docker exec -it $(CONTAINER_DEV) sh

.PHONY: dev-restart
dev-restart: dev-down dev-up ## 重启开发环境

# ============================================
# 测试环境命令
# ============================================
.PHONY: test
test: ## 启动测试环境（前台运行）
	@echo "🧪 启动测试环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_TEST) up

.PHONY: test-up
test-up: ## 启动测试环境（后台运行）
	@echo "🧪 启动测试环境（后台）..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_TEST) up -d
	@echo "✅ 测试环境已启动，访问地址: http://localhost:8082"

.PHONY: test-down
test-down: ## 停止测试环境
	@echo "⏹️  停止测试环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_TEST) down

.PHONY: test-logs
test-logs: ## 查看测试环境日志
	@echo "📋 查看测试环境日志..."
	docker logs -f $(CONTAINER_TEST)

.PHONY: test-shell
test-shell: ## 进入测试环境容器
	@echo "🐚 进入测试环境容器..."
	docker exec -it $(CONTAINER_TEST) sh

.PHONY: test-restart
test-restart: test-down test-up ## 重启测试环境

# ============================================
# 生产环境命令
# ============================================
.PHONY: prod
prod: ## 启动生产环境（前台运行）
	@echo "🚀 启动生产环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_PROD) up

.PHONY: prod-up
prod-up: ## 启动生产环境（后台运行）
	@echo "🚀 启动生产环境（后台）..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_PROD) up -d
	@echo "✅ 生产环境已启动，访问地址: http://localhost"

.PHONY: prod-down
prod-down: ## 停止生产环境
	@echo "⏹️  停止生产环境..."
	docker-compose -f $(COMPOSE_BASE) -f $(COMPOSE_PROD) down

.PHONY: prod-logs
prod-logs: ## 查看生产环境日志
	@echo "📋 查看生产环境日志..."
	docker logs -f $(CONTAINER_PROD)

.PHONY: prod-shell
prod-shell: ## 进入生产环境容器
	@echo "🐚 进入生产环境容器..."
	docker exec -it $(CONTAINER_PROD) sh

.PHONY: prod-restart
prod-restart: prod-down prod-up ## 重启生产环境

# ============================================
# 构建命令
# ============================================
.PHONY: build-dev
build-dev: ## 构建开发环境镜像
	@echo "🔨 构建开发环境镜像..."
	docker build --build-arg BUILD_ENV=development -t frontend-user:dev ./frontend-user

.PHONY: build-test
build-test: ## 构建测试环境镜像
	@echo "🔨 构建测试环境镜像..."
	docker build --build-arg BUILD_ENV=test -t frontend-user:test ./frontend-user

.PHONY: build-prod
build-prod: ## 构建生产环境镜像
	@echo "🔨 构建生产环境镜像..."
	docker build --build-arg BUILD_ENV=production -t frontend-user:prod ./frontend-user

.PHONY: build-all
build-all: build-dev build-test build-prod ## 构建所有环境镜像

# ============================================
# 工具命令
# ============================================
.PHONY: status
status: ## 查看所有容器状态
	@echo "📊 查看所有容器状态..."
	docker ps -a | grep watermark-remover

.PHONY: clean
clean: ## 清理所有停止的容器和悬空镜像
	@echo "🧹 清理Docker资源..."
	docker container prune -f
	docker image prune -f
	@echo "✅ 清理完成"

.PHONY: health
health: ## 检查所有容器健康状态
	@echo "❤️  检查容器健康状态..."
	@for container in $(CONTAINER_DEV) $(CONTAINER_TEST) $(CONTAINER_PROD); do \
		if docker ps -q -f name=$$container > /dev/null; then \
			status=$$(docker inspect --format='{{.State.Health.Status}}' $$container 2>/dev/null || echo "unknown"); \
			echo "$$container: $$status"; \
		else \
			echo "$$container: not running"; \
		fi \
	done

.PHONY: init-env
init-env: ## 初始化环境变量配置文件
	@echo "📝 初始化环境变量配置文件..."
	@if [ ! -f .env.development ]; then \
		cp .env.example .env.development; \
		echo "✅ 已创建 .env.development"; \
	else \
		echo "ℹ️  .env.development 已存在"; \
	fi
	@if [ ! -f .env.test ]; then \
		cp .env.example .env.test; \
		echo "✅ 已创建 .env.test"; \
	else \
		echo "ℹ️  .env.test 已存在"; \
	fi
	@if [ ! -f .env.production ]; then \
		cp .env.example .env.production; \
		echo "✅ 已创建 .env.production"; \
	else \
		echo "ℹ️  .env.production 已存在"; \
	fi
