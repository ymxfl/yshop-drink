## 1. 后端 — 统一可用券查询

- [x] 1.1 在 `AppCouponUserService` / `AppCouponUserServiceImpl` 抽取 `countAvailable(uid)` 方法：`status=0` + `startTime < now` + `endTime > now`
- [x] 1.2 修复 `MemberUserServiceImpl.getAppUser()`：将 `IS_STATUS_1` 改为调用 `countAvailable(uid)` 设置 `couponCount`
- [x] 1.3 确认 `/coupon/count` 与 `/coupon/my?type=0` 条件与 `countAvailable` 语义一致（支付页多 shopId/type 过滤，保持不变）

## 2. 后端 — 领取与未领列表校验

- [x] 2.1 在 `ErrorCodeConstants` 新增 `COUPON_NOT_VALID`（或 `COUPON_EXPIRED`）错误码及中文提示
- [x] 2.2 在 `AppCouponServiceImpl.receive()` 保存前校验 `startTime <= now < endTime`，不满足则抛异常
- [x] 2.3 在 `AppCouponServiceImpl.getNotList()` 增加 `startTime < now` 过滤（与 endTime 组成完整有效期窗口）

## 3. 前端 — 优惠券页 Tab 扩展

- [x] 3.1 在 `coupons.vue` 增加 Tab：「已使用」(type=1)、「已过期」(type=2)，复用 `couponMine` API
- [x] 3.2 为 type=1/2 列表添加对应 UI（已使用/已过期样式，隐藏「立即使用」按钮）
- [x] 3.3 Tab 切换时调用 `getCoupons(index)` 加载对应数据

## 4. 前端 — 领取后刷新

- [x] 4.1 `receive()` 成功后调用 `getCoupons(0)` 刷新「我的优惠券」
- [x] 4.2 `receive()` / `exchange()` 成功后调用 `userGetUserInfo()` 更新 `member.couponCount`
- [x] 4.3 在 `index.vue` 增加 `onShow` 钩子，登录状态下刷新用户信息

## 5. 验证

- [x] 5.1 用测试账号验证：过期券不在「我的优惠券」和首页计数中，但出现在「已过期」Tab
- [x] 5.2 验证领取过期券模板返回业务错误，不再写入数据库
- [x] 5.3 验证领取有效券后，首页数字与「我的优惠券」列表同步更新
- [ ] 5.4 （可选）为用户 17600169392 延长券 id=8 的 end_time 以验证修复后可用
