/** 优先 .env 中 VITE_APP_API_URL；未配置时 H5 跟随页面 host，小程序等默认本机 */
function resolveApiBaseUrl() {
  const fromEnv = import.meta.env.VITE_APP_API_URL
  if (fromEnv) {
    return String(fromEnv).replace(/\/$/, '')
  }

  // #ifdef H5
  if (typeof window !== 'undefined' && window.location?.hostname) {
    const { hostname, origin } = window.location
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return `http://${hostname}:48081/app-api`
    }
    return `${origin}/app-api`
  }
  // #endif

  return 'http://127.0.0.1:48081/app-api'
}

export const VUE_APP_API_URL = resolveApiBaseUrl()
// 静态资源走打包产物，不依赖外部 CDN
export const VUE_APP_RESOURCES_URL = '/static'
export const VUE_APP_UPLOAD_URL = VUE_APP_API_URL + '/infra/file/upload'
// 仅 H5 在微信内 OAuth 使用；只做小程序可忽略
export const APP_ID = 'wxdbdbc123c8c30b45'

const orderListStatus = {}

// -1:申请退款
// -2:退货成功
// 0:待发货；
// 1:待收货；
// 2:已收货；
// 3:待评价；
// -1:已退款

export const orderStatus = {
  0: '未支付',
  1: '待发货',
  2: '待收货',
  3: '待评价',
  4: '已完成',
  5: '退款中',
  6: '已退款',
  7: '退款',
}

export const orderReStatus = {
  0: '等待买家付款',
  // 1: '等待卖家发货',
  1: '卖家已发货',
  2: '等待买家待评价',
  3: '订单已完成',
  4: '订单退款中',
  5: '订单已退款',
  6: '退款已完成',
}

// export const orderReStatus = {
//   0: '等待买家付款',
//   1: '等待卖家发货',
//   2: '卖家已发货',
//   3: '等待买家待评价',
//   4: '订单已完成',
//   5: '订单退款中',
//   6: '订单已退款',
//   7: '退款已完成',
// }
