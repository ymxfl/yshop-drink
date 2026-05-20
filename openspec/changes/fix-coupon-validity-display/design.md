## Context

yshop-drink 优惠券模块存在三处独立的查询逻辑，对「可用券」定义不一致：

| 入口 | 当前条件 | 问题 |
|------|---------|------|
| 首页 `couponCount`（`MemberUserServiceImpl`） | `status = IS_STATUS_1`（已使用） | 枚举用错，且不过滤有效期 |
| 列表 `/coupon/my?type=0` | `status=0` + 有效期内 | 正确，作为基准 |
| 支付 `/coupon/count` | `status=0` + 有效期内 + 店铺/类型 | 正确 |
| 领取 `POST /coupon/receive` | 无有效期校验 | 可领取过期券 |
| 未领列表 `/coupon/not` | 仅 `endTime > now` | 未校验 startTime |

生产环境实测：用户 17600169392 持有 1 张 status=0 但 end_time=2025-09-12 的过期券，列表为空但用户感知「有券看不到」。

## Goals / Non-Goals

**Goals:**

- 全端统一「当前可用券」= status=0 且 start_time ≤ now < end_time
- 首页卡券数与列表「我的优惠券」Tab 数量一致
- 阻止领取/展示不可用的券模板
- 前端提供「已使用 / 已过期」Tab，历史券可查
- 领取成功后即时刷新计数和列表

**Non-Goals:**

- 不自动延长或修复已有过期券数据（运营可在后台手动延期）
- 不改管理后台优惠券 CRUD 界面
- 不改支付页选券逻辑（已正确，仅确认对齐）
- 不引入优惠券到期提醒推送

## Decisions

### 1. 抽取统一的「可用券」查询条件

**决定**：在后端 `AppCouponUserService` 新增 package-private 或 static 辅助方法 `buildAvailableWrapper(uid, shopId, type)`，供 `getList`、`getAppUser` 计数、以及未来扩展复用。

**理由**：避免三处 copy-paste 条件再次漂移。

**备选**：只在 `MemberUserServiceImpl` 内联修复 → 拒绝，无法防止后续不一致。

### 2. 修复 `MemberUserServiceImpl.couponCount`

**决定**：改为 `status = IS_STATUS_0`，并加上 `startTime < now AND endTime > now`（与 `/coupon/my type=0` 一致，不限 shopId）。

**理由**：首页展示的是用户全局可用券总数，不应含已使用或过期券。

**注意**：当前代码误用 `IS_STATUS_1`，属明确 bug。

### 3. 领取接口增加有效期校验

**决定**：在 `AppCouponServiceImpl.receive()` 保存前校验：

```
now >= couponDO.startTime && now < couponDO.endTime
```

不满足则抛出业务异常（新增 ErrorCode `COUPON_EXPIRED` 或复用已有码）。

**理由**：产品层阻断「领了用不了」的路径。

### 4. 未领券列表补齐 startTime 过滤

**决定**：`getNotList()` 增加 `.lt(CouponDO::getStartTime, nowTime)` 与 `.gt(CouponDO::getEndTime, nowTime)`（后者已有）。

**理由**：未开始的券不应出现在「去领券」列表。

### 5. 前端 Tab 扩展

**决定**：`coupons.vue` 在现有两个 Tab 基础上增加：

- Tab 0：我的优惠券（type=0，可用）
- Tab 1：未领优惠券（不变）
- Tab 2：已使用（type=1）
- Tab 3：已过期（type=2）

**理由**：后端 `CouponStatusEnum` 已支持 type=1/2，前端缺失导致历史券「消失」。

**备选**：仅两个 Tab + 空态文案 → 拒绝，无法解决过期券不可见。

### 6. 领取成功后刷新策略

**决定**：

- `receive()` / `exchange()` 成功后调用 `getCoupons(0)` + `userGetUserInfo()` → `SET_MEMBER`
- `index.vue` 增加 `onShow` 调用 `getUserInfo()`（与 mine 页一致）

**理由**：消除缓存导致的数字不同步。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| `couponCount` 数值下降（更准确） | 预期行为；可在发布说明中说明 |
| 已有过期券用户看不到「可用」Tab | 「已过期」Tab 可查看 |
| 领取接口拒绝过期券可能影响运营测试 | 后台可延期券模板 end_time |
| Tab 增多 UI 拥挤 | 使用横向 scroll tab 或合并「已使用/已过期」为「历史卡券」子 Tab — 首版用 4 Tab，后续可优化 |

## Migration Plan

1. 部署后端（领取校验 + 计数修复 + 未领列表过滤）
2. 部署 uniapp 前端（Tab + 刷新逻辑）
3. 无需 DB 迁移
4. 回滚：还原代码即可，无 schema 变更

## Open Questions

- 是否在管理后台增加「过期券自动下架」（`is_switch=0`）定时任务？→ 本次不做，可后续 change 跟进
- 「已使用 / 已过期」是否合并为一个「历史卡券」Tab？→ 首版分开，与后端 type 一一对应，实现更简单
