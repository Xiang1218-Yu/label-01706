# 环境配置说明

## 目录结构
```
config/
├── dev.env.js      # 开发环境配置
├── test.env.js     # 测试环境配置
├── prod.env.js     # 生产环境配置
└── README.md       # 配置说明文档
```

## 配置说明

### 1. 开发环境(dev)
- 适用场景：本地开发、功能调试
- 特点：开启debug模式，关闭统计上报
- 分支对应：`dev`分支
- API地址：`http://dev-api.example.com`

### 2. 测试环境(test)
- 适用场景：测试团队测试、UAT用户验收测试
- 特点：开启debug模式，开启统计上报
- 分支对应：`test`分支
- API地址：`http://test-api.example.com`

### 3. 生产环境(prod)
- 适用场景：正式线上环境
- 特点：关闭debug模式，开启统计上报
- 分支对应：`main`分支
- API地址：`https://api.example.com`

## 配置项说明

| 配置项 | 类型 | 说明 |
|--------|------|------|
| ENV | string | 环境标识：dev/test/prod |
| API_BASE_URL | string | API接口基础地址 |
| FEATURE_FLAGS.DEBUG | boolean | 是否开启调试模式 |
| FEATURE_FLAGS.MOCK | boolean | 是否开启Mock数据 |
| FEATURE_FLAGS.ANALYTICS | boolean | 是否开启统计上报 |
| APP_NAME | string | 应用名称 |
| VERSION | string | 应用版本号 |

## 使用方式

### 1. 本地开发使用
将对应环境的配置文件复制到`js/env.js`：
```bash
# 开发环境
cp config/dev.env.js js/env.js

# 测试环境
cp config/test.env.js js/env.js

# 生产环境
cp config/prod.env.js js/env.js
```

### 2. CI/CD自动注入
CI/CD工作流会根据当前分支自动选择对应的配置文件：
- `dev`分支 -> 自动使用`dev.env.js`
- `test`分支 -> 自动使用`test.env.js`
- `main`分支 -> 自动使用`prod.env.js`

### 3. 代码中使用
在JavaScript代码中可以直接通过`window.ENV`访问配置：
```javascript
console.log('当前环境:', window.ENV.ENV)
console.log('API地址:', window.ENV.API_BASE_URL)
```

## 注意事项
1. 请勿直接修改`js/env.js`文件，该文件会在构建时自动覆盖
2. 敏感信息不要提交到代码库，应该通过环境变量或秘钥管理系统注入
3. 修改配置后需要重新构建镜像才能生效
4. 不同环境的配置需要保持字段一致，避免出现兼容性问题
