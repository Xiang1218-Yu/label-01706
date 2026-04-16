/**
 * 开发环境配置
 * 用于本地开发和测试环境
 */
window.ENV = {
  // 环境标识
  ENV: 'dev',
  // API接口地址
  API_BASE_URL: 'http://dev-api.example.com',
  // 功能开关
  FEATURE_FLAGS: {
    DEBUG: true,
    MOCK: false,
    ANALYTICS: false
  },
  // 其他配置
  APP_NAME: '批量去水印工具(开发版)',
  VERSION: '1.0.0-dev'
}
