/**
 * 测试环境配置
 * 用于测试团队测试和用户验收测试
 */
window.ENV = {
  // 环境标识
  ENV: 'test',
  // API接口地址
  API_BASE_URL: 'http://test-api.example.com',
  // 功能开关
  FEATURE_FLAGS: {
    DEBUG: true,
    MOCK: false,
    ANALYTICS: true
  },
  // 其他配置
  APP_NAME: '批量去水印工具(测试版)',
  VERSION: '1.0.0-test'
}
