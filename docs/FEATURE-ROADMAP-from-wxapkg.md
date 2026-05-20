# 从商业小程序反编译包借鉴的功能路线图（yshop-drink）

> **参考来源**：`/Users/joshua/GitHub/KillWxapkg/wxapkg_output_v24`（迎东/eingdong 类 SaaS 餐饮小程序反编译产物）  
> **目标项目**：`yshop-drink`（Spring Boot3 + Vue3 管理端 + UniApp 小程序/H5）  
> **说明**：本文仅作产品与技术规划参考；反编译代码不可直接商用拷贝，应基于 yshop 架构自行实现。  
> **更新**：2026-05-19

---

## 优先级定义

| 级别 | 含义 | 建议节奏 |
|------|------|----------|
| **P0** | 补齐核心点餐闭环缺口；后端大多已有或可小改 | 1～2 个迭代 |
| **P1** | 明显提升留存与客单价；需在现有模块上扩展 | 2～4 个迭代 |
| **P2** | 营销差异化；新表 + 新流程，复杂度中等 | 按季度规划 |
| **P3** | 垂类或重集成；投入大或依赖第三方 | 按需选型 |

**评估维度**：业务价值 · 与 yshop 架构契合度 · 现有代码复用度 · 前后端工作量 · 合规/第三方依赖

---

## P0 — 建议优先实现（补齐主流程）

### 1. 扫码堂食 / 桌台点餐（desk）

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/code/code`、`goods/mult-user`（多人协同）、`packageA/pages/table_timeout` |
| **yshop 现状** | 后端已支持 `orderType=desk`、`deskId/deskNumber/deskPeople`；管理端订单可展示桌号；**UniApp 未实现** |
| **建议实现** | ① 桌台二维码解析（scene → shopId + deskId）② 点餐页增加堂食模式 ③ 下单传 desk 字段 ④ 管理端桌台 CRUD（若尚无） |
| **涉及** | `yshop-module-order`、`yshop-module-store`、UniApp `menu` / `pay` |
| **工作量** | 中（前端为主，后端小改） |
| **价值** | README 已宣传能力，补齐后与竞品基础对齐 |

### 2. 预约取餐时间（自取/外卖时段）

| 项 | 说明 |
|----|------|
| **反编译参考** | `packageB/pages/preorder`、`myPreorder`；点单页时间选择组件 `timePicker` |
| **yshop 现状** | 订单实体有 `getTime`；管理端列表有「预约取餐时间」列；小程序结算页**未选时段** |
| **建议实现** | ① 门店配置可预约时段/提前分钟数 ② 结算页时间选择器 ③ 下单写入 `getTime` ④ 门店端/打印展示预约时间 |
| **涉及** | `store` 配置、`order`、UniApp `pay` |
| **工作量** | 中 |
| **价值** | 茶饮/快餐高峰削峰，减少现场等待纠纷 |

### 3. 会员充值完整闭环（小程序页 + 支付）

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/topUp`、`pages/topUp_list`、`components/upage/rechargeoptions` |
| **yshop 现状** | 已有 `/recharge/getMoneyList`、`/member/user/recharge`；`bill.vue` 有充值入口；**无独立充值页与支付回调闭环展示** |
| **建议实现** | ① 充值档位页 ② 调起微信支付 ③ 充值记录列表 ④ 管理端充值订单/流水（若缺失则补） |
| **涉及** | `yshop-module-member`、`yshop-module-pay`、UniApp 新页面 |
| **工作量** | 中 |
| **价值** | 直接提升储值与复购，ROI 高 |

### 4. 取餐号 / 取餐状态（叫号取餐）

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/takeMeals`、`order` 列表态、取餐码展示 |
| **yshop 现状** | 订单有取餐/配送状态；小程序订单页偏简 |
| **建议实现** | ① 下单成功页展示取餐号/二维码 ② 订单详情态：制作中/请取餐/已完成 ③ 可选订阅消息提醒 |
| **涉及** | `order`、`message`（模板消息已有基础） |
| **工作量** | 小～中 |
| **价值** | 自取场景体验刚需 |

### 5. 订单评价（C 端提交 + 展示）

| 项 | 说明 |
|----|------|
| **反编译参考** | `packageA/pages/review`、`reviewlist`、`review-success` |
| **yshop 现状** | 已有 `StoreProductReply` 及管理端审核；App 端查询 VO 存在；**小程序无评价入口** |
| **建议实现** | ① 已完成订单「去评价」 ② 星级+图文（复用 infra 文件上传） ③ 商品详情展示评价列表 |
| **涉及** | `yshop-module-product`、UniApp `orders/detail` |
| **工作量** | 中 |
| **价值** | 复用现有表与服务，投入小、信任感提升明显 |

---

## P1 — 第二梯队（运营与会员体系）

### 6. 签到领积分

| 项 | 说明 |
|----|------|
| **反编译参考** | `packageA/pages/signin`、`signin_rule` |
| **yshop 现状** | 会员有 `integral` 字段；无签到模块 |
| **建议实现** | 签到规则表、连续签到奖励、小程序签到页、管理端规则配置 |
| **工作量** | 中 |
| **价值** | 低成本日活手段 |

### 7. 邀请有礼 / 分享拉新

| 项 | 说明 |
|----|------|
| **反编译参考** | `packageA/pages/invitation`、`share_friend_page`、`pages/share_page` |
| **yshop 现状** | 无分销/邀请模块；有分享能力可接小程序 `onShareAppMessage` |
| **建议实现** | 邀请码绑定、首单奖励（券/积分）、邀请记录页；管理端活动配置 |
| **工作量** | 中～大 |
| **价值** | 获客；需注意微信诱导分享规范 |

### 8. 优惠券能力增强

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/coupon`、`getNewCoupon`、`couponAssistant`、`gift_coupon` |
| **yshop 现状** | `yshop-module-marketing` 优惠券 + 领取/使用；缺「弹窗领券」「下单凑单提示」 |
| **建议实现** | ① 首页/点餐页可领券弹层 ② 结算页可用券列表与凑单提示 ③ 赠券活动（发券到账户） |
| **工作量** | 中 |
| **价值** | 在现有券系统上增强 UX，无需重做券引擎 |

### 9. 会员等级 / VIP 页

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/vipPage`、`packageC/pages/vipPage/grade`、`upage/vipequity`、`memberPoints` |
| **yshop 现状** | 用户详情有成长值相关字段引用；`vip_card` 账单类型；**无完整等级体系页** |
| **建议实现** | 等级规则（消费/积分升级）、权益说明页、个人中心等级进度条 |
| **工作量** | 中～大 |
| **价值** | 提升高价值用户粘性 |

### 10. 首页可配置化（轻量版 UPage）

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/upage/upage`、`components/upage/*`、`LowCode/*` |
| **yshop 现状** | 首页写死 Banner + 自取/外卖；管理端有 `shop/ads` 广告位 |
| **建议实现** | **不建议一期做完整低代码**；可做：轮播 + 金刚区入口 + 公告栏 + 推荐商品，配置存 JSON，小程序动态渲染 |
| **工作量** | 大（若做全量低代码）；轻量版中 |
| **价值** | 运营可自助改首页，减少发版 |

### 11. 门店地图选店 / 附近门店优化

| 项 | 说明 |
|----|------|
| **反编译参考** | `pages/map`、`upage/nearbyStores`、`packageB/pages/switch_city` |
| **yshop 现状** | 有门店列表、距离字段；管理端 `store/shop/map.vue` |
| **建议实现** | 地图选店、按距离排序、营业状态、收藏常去门店 |
| **工作量** | 中 |
| **价值** | 多门店体验标配 |

### 12. 订单退款 / 售后流程完善（C 端）

| 项 | 说明 |
|----|------|
| **反编译参考** | `packageB/pages/refund`、`packagePeripheryShopping/.../requestRefund` |
| **yshop 现状** | 有 `orders/refund` 页；管理端 `StoreOrderRefund` |
| **建议实现** | 对齐状态机：申请→审核→退款；退款原因、凭证上传、进度查询 |
| **工作量** | 中 |
| **价值** | 降低客服成本 |

---

## P2 — 第三梯队（营销玩法，需新建域模型）

### 13. 限时秒杀 / 特价菜

| 反编译参考 | `packageA/pages/seckillActivity`、`goods/goods-limit-sale`、`limit-sale-time` |
| 建议 | 活动表 + 库存扣减 + 倒计时 UI；与现有 SKU 价格体系集成 |
| 工作量 | 大 |
| 注意 | 高并发库存、超卖防护 |

### 14. 拼团 / 套餐组合（combo）

| 反编译参考 | `packageA/pages/combo/*`、`pages/assemble` |
| 建议 | 固定组合套餐价；真拼团需成团逻辑、分享、超时关单 |
| 工作量 | 大 |
| 建议节奏 | 先做「固定套餐」再做「社交拼团」 |

### 15. 积分商城增强（物流 / 兑换记录）

| 反编译参考 | `packageC/pages/jifensc/*`（exchange、exRecord、expressInfo） |
| yshop 现状 | `yshop-module-score` + 小程序 `scoreproduct` 基础流程已有 |
| 建议 | 补兑换记录、物流单号、失败售后；与 `yshop-module-express` 打通 |
| 工作量 | 中 |

### 16. 礼品卡 / 储值卡赠送

| 反编译参考 | `packageB/pages/gift_crat/*` |
| 建议 | 卡密/转赠/领取；涉及资金与风控 |
| 工作量 | 大 |

### 17. 订单抽奖

| 反编译参考 | `packageB/pages/order_lottery` |
| 建议 | 支付成功页抽奖；奖品池、概率、防刷 |
| 工作量 | 中～大 |

### 18. 生日礼 / 节日活动页

| 反编译参考 | `packageB/pages/birthday_gift`、`pages/market`、`uspecial` |
| 建议 | 会员生日字段 + 定时发券；专题页用可配置 H5/小程序页 |
| 工作量 | 中 |

### 19. 口令券 / 活动码兑换

| 反编译参考 | `packageB/pages/shibboleth/*` |
| 建议 | 与优惠券模块结合：口令兑换券 |
| 工作量 | 小～中 |

### 20. 徽章 / 成就体系

| 反编译参考 | `pages/badge`、`packageA/pages/badge/*` |
| 建议 | 偏品牌运营；非餐饮刚需，可后置 |
| 工作量 | 中 |

---

## P3 — 低优先级或慎选（重集成 / 垂类 / 合规）

| 功能 | 反编译参考 | 不建议优先的原因 | 若要做 |
|------|------------|------------------|--------|
| 美团/抖音团购核销 | `meituan-group-list`、`douyin_ticket` | 强依赖第三方开放平台与资质 | 单独立项对接开放平台 |
| 周边商城独立子包 | `packagePeripheryShopping` | 接近独立电商，与点餐 SKU 体系不同 | 评估是否用积分商城扩展代替 |
| 粉丝分销 / 提现 | `myfans`、`withdraw` | 合规、税务、微信分账复杂 | 需法务与支付方案 |
| 代付 / 帮付 | `helppay`、`pay_for` | 支付风控与场景限制 | 评估微信规则 |
| 存酒 | `winestorage` | 强垂类（酒吧） | 仅酒类客户需要 |
| 电子发票 | `packageB/pages/invoice/*` | 需税控/第三方发票服务 | 对接诺诺/百望等 |
| 排队取号 | `packageA/pages/etc/*` | 与点餐排队场景部分重叠 | 可先做单店简易排队 |
| 低代码全量 UPage | `LowCode`、`upage` 全组件 | 研发成本极高 | 用 P1「轻量可配置首页」代替 |
| 微信小店组件 | `wxStore`、`wxStoreGoods` | 依赖微信小店开通 | 按平台政策选型 |
| WiFi 连网 | `packageC/pages/wifi` | 非点餐核心 | 可选增值 |
| 食品安全公示 | `food_safety` | 展示型，内容来自后台配置 | 静态页 + 后台富文本即可 |

---

## 不建议从反编译包借鉴的部分

1. **直接复制反编译 JS/WXML**：版权与许可风险，且与 UniApp/Vue3 技术栈不一致。  
2. **对接 eingdong 云端 API**：与 yshop 自建后端架构冲突，无法私有化。  
3. **完整低代码引擎**：投入产出比低；优先 JSON 配置 + 有限组件集。  
4. **云小票打印逻辑照抄**：yshop 开源版打印为商业版能力，应走官方插件或自有打印 SDK 集成。

---

## 推荐实施顺序（里程碑）

```text
阶段 A（P0，约 4～6 周）
  desk 堂食 → 预约取餐时间 → 充值闭环 → 取餐号/状态 → 订单评价

阶段 B（P1，约 6～10 周）
  签到 → 券 UX 增强 → VIP 等级页 → 地图选店 → 退款流程 → 轻量可配置首页

阶段 C（P2，按业务选型）
  秒杀 / 套餐 → 积分物流 → 口令券 → 专题活动页

阶段 D（P3）
  仅在有明确商务合同或资质时做：团购核销、发票、分销等
```

---

## 与 yshop 模块映射（实施时对照）

| 功能域 | 主要后端模块 | 主要前端 |
|--------|--------------|----------|
| 点餐/订单/桌台 | `yshop-module-mall`（order、store、product） | UniApp `menu`、`pay`、`order` |
| 会员/充值 | `yshop-module-member`、`yshop-module-pay` | `mine`、`balance`、新 `recharge` |
| 优惠券 | `yshop-module-marketing` | `coupons`、`packages` |
| 积分商城 | `yshop-module-score` | `scoreproduct/*` |
| 消息触达 | `yshop-module-message`、`mp` | 订阅消息、模板消息 |
| 物流 | `yshop-module-express` | 积分订单详情 |
| 运营配置 | `shop/ads`、infra 文件 | `index` 动态化 |

---

## 附录：反编译包页面索引（便于产品对照）

<details>
<summary>主包 Tab 与核心页</summary>

- Tab：首页 `upage` · 点单 `goods` · 订单 `order` · 积分商城 `jifensc` · 我的 `my-page`
- 充值 `topUp` / `topUp_list` · 会员 `vipPage` · 优惠券 `coupon` · 取餐 `takeMeals` · 地图 `map`

</details>

<details>
<summary>子包 packageA（会员/活动）</summary>

签到、邀请、评价、存酒、秒杀、拼团套餐、排队、徽章、预点单等

</details>

<details>
<summary>子包 packageB（交易/预约/营销）</summary>

预约、Preorder、发票、退款、自助结账、口令、礼品卡、美团/抖音券、城市切换等

</details>

<details>
<summary>子包 packageC / packagePeripheryShopping</summary>

积分兑换增强、WiFi、周边电商全流程

</details>

---

## 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-19 | 初版：基于 wxapkg_output_v24 与 yshop-drink 代码结构对比编写 |
