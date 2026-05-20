import api from '@/api/api'

/**
 * couponReceive
 */
export function couponReceive(data) {
  return api.post('/coupon/receive', data, { login: false })
}

/**
 * couponMine
 */
export function couponMine(data) {
  return api.get(`/coupon/my`, data, { login: false })
}

/**
 * couponIndex
 */
export function couponIndexApi(data) {
  return api.get(`/coupon/not`, data, { login: false })
}

/**
 * couponCount
 */
export function couponCount(data) {
  return api.get(`/coupon/count`, data, { login: false })
}
