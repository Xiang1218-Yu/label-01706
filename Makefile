# ============================================
# Makefile - 项目构建和部署工具
# 提供便捷的命令来管理 Docker 容器
# ============================================

# 默认目标
.DEFAULT_GOAL := help

# 环境变量
ENV ?= development
COMPOSE_FILES := -f docker-compose.yml

# 根据环境选择配置文件
ifeq ($(ENV), development)
	COMPOSE_FILES += -f docker-compose.dev.yml
	ENV_FILE := .env.development
else ifeq ($(ENV), testing)
	COMPOSE_FILES += -f docker-compose.test.yml
	ENV_FILE := .env.testing
else ifeq ($(ENV), production)
	COMPOSE_FILES += -f docker-compose.prod.yml
	ENV_FILE := .env.production
endif

# ============================================
# 帮助信息
# ============================================
.PHONY: help
help: ## 显示帮助信息
	@echo "=========================================="
	@echo "Frontend User - 项目管理工具"
	@echo "=========================================="
	@echo ""
	@echo "使用方法:"
	@echo "  make [目标] [ENV=环境]"
	@echo ""
	@echo "环境选项:"
	@echo "  ENV=development  - 开发环境（默认）"
	@echo "  ENV=testing      - 测试环境"
	@echo "  ENV=production   - 生产环境"
	@echo ""
	@echo "可用目标:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ============================================
# 开发环境命令
# ============================================
.PHONY: up
up: ## 启动服务
	@echo "启动 $(ENV) 环境服务..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) up -d

.PHONY: down
down: ## 停止服务
	@echo "停止 $(ENV) 环境服务..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) down

.PHONY: restart
restart: ## 重启服务
	@echo "重启 $(ENV) 环境服务..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) restart

.PHONY: logs
logs: ## 查看日志
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) logs -f

.PHONY: shell
shell: ## 进入容器 Shell
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) exec frontend-user sh

.PHONY: build
build: ## 构建镜像
	@echo "构建 $(ENV) 环境镜像..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) build

.PHONY: rebuild
rebuild: ## 重新构建镜像（无缓存）
	@echo "重新构建 $(ENV) 环境镜像..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) build --no-cache

.PHONY: status
status: ## 查看服务状态
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) ps

.PHONY: health
health: ## 查看健康检查状态
	docker inspect --format='{{.State.Health.Status}}' frontend-user-$(ENV)

# ============================================
# 清理命令
# ============================================
.PHONY: clean
clean: ## 清理容器和镜像
	@echo "清理 $(ENV) 环境..."
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) down -v --rmi all

.PHONY: prune
prune: ## 清理 Docker 系统（谨慎使用）
	docker system prune -f

# ============================================
# 快速命令
# ============================================
.PHONY: dev
dev: ## 快速启动开发环境
	@$(MAKE) up ENV=development

.PHONY: test
test: ## 快速启动测试环境
	@$(MAKE) up ENV=testing

.PHONY: prod
prod: ## 快速启动生产环境
	@$(MAKE) up ENV=production

# ============================================
# 其他工具
# ============================================
.PHONY: config
config: ## 查看 Docker Compose 配置
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) config

.PHONY: pull
pull: ## 拉取最新镜像
	docker-compose $(COMPOSE_FILES) --env-file $(ENV_FILE) pull
