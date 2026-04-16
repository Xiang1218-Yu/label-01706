#!/bin/bash
# 多环境部署脚本
# 使用方式: ./deploy.sh [环境] [操作]
# 环境: dev / test / prod
# 操作: up / down / restart / logs / build / exec
# 示例:
#   ./deploy.sh dev up      # 启动开发环境
#   ./deploy.sh prod down   # 停止生产环境
#   ./deploy.sh test logs   # 查看测试环境日志

set -e

# 检查参数
if [ $# -lt 1 ]; then
    echo "使用方式: $0 [环境] [操作]"
    echo "环境: dev / test / prod"
    echo "操作: up / down / restart / logs / build / exec"
    exit 1
fi

ENV=$1
ACTION=${2:-up}

# 检查环境是否有效
if [ ! -f ".env.${ENV}" ]; then
    echo "错误: 环境配置文件 .env.${ENV} 不存在"
    echo "支持的环境: dev, test, prod"
    exit 1
fi

# 加载环境变量
export $(grep -v '^#' .env.${ENV} | xargs)

echo "====================================="
echo "当前环境: ${ENV}"
echo "容器名称: ${CONTAINER_NAME}"
echo "服务端口: ${PORT}"
echo "操作: ${ACTION}"
echo "====================================="

# 开发环境特殊处理：启用热重载挂载
if [ "${ENV}" == "dev" ]; then
    export DEV_MOUNT="."
    echo "开发环境：已启用热重载"
else
    export DEV_MOUNT="./empty"
fi

# 执行操作
case ${ACTION} in
    "up")
        echo "启动 ${ENV} 环境..."
        docker-compose --env-file .env.${ENV} up -d --build
        echo "✅ 启动完成，访问地址: http://localhost:${PORT}"
        ;;
    
    "down")
        echo "停止 ${ENV} 环境..."
        docker-compose --env-file .env.${ENV} down
        echo "✅ 已停止"
        ;;
    
    "restart")
        echo "重启 ${ENV} 环境..."
        docker-compose --env-file .env.${ENV} restart
        echo "✅ 重启完成"
        ;;
    
    "logs")
        echo "查看 ${ENV} 环境日志..."
        docker-compose --env-file .env.${ENV} logs -f --tail=100
        ;;
    
    "build")
        echo "构建 ${ENV} 环境镜像..."
        docker-compose --env-file .env.${ENV} build
        echo "✅ 构建完成"
        ;;
    
    "exec")
        echo "进入 ${ENV} 环境容器..."
        docker-compose --env-file .env.${ENV} exec frontend sh
        ;;
    
    "status")
        echo "查看 ${ENV} 环境状态..."
        docker-compose --env-file .env.${ENV} ps
        ;;
    
    *)
        echo "错误: 不支持的操作 ${ACTION}"
        echo "支持的操作: up, down, restart, logs, build, exec, status"
        exit 1
        ;;
esac

exit 0
