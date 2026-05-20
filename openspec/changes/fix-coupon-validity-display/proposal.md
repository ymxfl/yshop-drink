## Why

用户领取优惠券后，首页「我的卡券」显示有券，但「我的优惠券」列表为空，造成困惑和不信任。根因是首页计数、列表查询、领取接口三处对「可用优惠券」的定义不一致：首页可能统计未使用但已过期的券，列表只显示当前有效期内且未使用的券，领取接口却不校验有效期，允许领取已过期仍上架的券模板。

以手机号 17600169392 为例：库中存在 1 张 status=0 的券，但 end_time 为 2025-09-12（已过期），列表过滤后为空，用户感知为「领了券却看不到」。

## What Changes

- 统一「可用优惠券」定义：未使用（status=0）且在有效期内（start_time ≤ now < end_time）
- 修复首页 `couponCount` 统计逻辑，与列表页和支付页 `/coupon/count` 保持一致
- 领取接口增加有效期校验，拒绝领取未开始或已过期的优惠券
- 「未领优惠券」列表不再展示已过期或未开始的券模板
- 领取成功后前端刷新「我的优惠券」和用户卡券数量
- 优惠券页增加「已使用 / 已过期」Tab，让用户能看到历史券（后端已支持 type=1/2，前端未接入）

## Capabilities

### New Capabilities

- `coupon-availability`: 定义优惠券「可用」的统一判定规则，覆盖领取、计数、列表展示三端行为

### Modified Capabilities

<!-- 无现有 openspec spec，本次为新增 capability -->

## Impact

- **后端**
  - `MemberUserServiceImpl.getAppUser()` — couponCount 统计条件
  - `AppCouponServiceImpl.receive()` — 领取前有效期校验
  - `AppCouponServiceImpl.getNotList()` — 未领券列表过滤 start_time
  - `AppCouponUserServiceImpl.getList()` — 行为不变，作为列表基准
- **前端（uniapp）**
  - `pages/components/pages/coupons/coupons.vue` — 新增 Tab、领取后刷新
  - `pages/index/index.vue` — onShow 刷新用户信息
- **API 行为变更**
  - `POST /coupon/receive` 对过期/未开始券返回错误（非 breaking，属 bug fix）
  - `GET /member/user/get-info` 的 `couponCount` 数值可能变小（更准确）
- **数据**
  - 无需迁移；已有过期券仍可通过「已过期」Tab 查看
