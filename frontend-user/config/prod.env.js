/**
 * 生产环境配置
 * 用于正式线上环境
 */
window.ENV = {
  // 环境标识
  ENV: 'prod',
  // API接口地址
  API_BASE_URL: 'https://api.example.com',
  // 功能开关
  FEATURE_FLAGS: {
    DEBUG: false,
    MOCK: false,
    ANALYTICS: true
  },
  // 其他配置
  APP_NAME: '批量去水印工具',
  VERSION: '1.0.0'
}
