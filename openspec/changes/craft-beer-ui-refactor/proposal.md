## Why

为了将当前的多品类/奶茶点餐小程序转型为针对“精酿啤酒及高端酒水”的专营零售小程序，我们需要重构前端 UI。
重构的目标是在**不改变现有核心业务功能**（自取、外卖、购物车、积分、卡券、订单等）的前提下，通过对全局设计系统（配色、字号、间距）、公共组件和各个页面的样式与模板进行彻底重设，使其具备符合高端精酿零售的“微醺酒吧风格”（暗色调、琥珀金、高端扁平化视觉）。

## What Changes

- **基础样式系统升级**：
  - 更新 `src/uni.scss`，定义以深灰/炭黑 (`#121212`, `#1E1E1E`) 为底，琥珀金/麦芽黄 (`#D4AF37`, `#F2A900`) 为主色的暗色主题变量。
  - 重构全局辅助工具类（如卡片圆角、阴影等样式）。
- **静态资源更新**：
  - 替换原有的卡通版切图与图标，使用金色线性/微醺风格的高保真 SVG/PNG 资产。
- **页面级 UI 重构（保持逻辑不变）**：
  - **首页 (`pages/index/index.vue`)**：重新设计顶部高清 Swiper 广告区、半透明玻璃拟态会员信息卡、极速配送/到店自取大卡片、金色啤酒杯集点卡系统，以及积分/领券快捷入口。
  - **点餐/商品列表页 (`pages/menu/menu.vue`)**：改造成适配暗黑色系的商品分类与多属性规格选择弹窗，突出精酿酒瓶与罐装视觉。
  - **购物车与支付结算页 (`pages/cart/cart.vue`, `pages/pay/pay.vue`)**：重构商品条目卡片、地址选择栏与付款信息展示，使其高度契合整体暗金质感。
  - **订单与个人中心页 (`pages/order/order.vue`, `pages/mine/mine.vue`)**：重构订单列表、详情面板、历史记录与个人主页样式。

## Capabilities

### New Capabilities

- `craft-beer-theme`: 精酿酒水专属暗黑金主题设计系统与全局 UI 变量组件规范。

### Modified Capabilities

- `member-home-ui`: 首页及会员信息卡片视觉。
- `order-funnel-ui`: 点餐、规格弹窗、购物车与结算页面的核心交易流视觉。

## Impact

- **前端（uniapp）**
  - `src/uni.scss` — 修改全局主题色及 UI 样式变量
  - `src/pages/index/index.vue` — 首页布局与 SCSS 样式重构
  - `src/pages/menu/menu.vue` — 商品选择列表、多规格弹窗 UI 升级
  - `src/pages/cart/cart.vue` & `src/pages/pay/pay.vue` — 购物车及支付结算页样式重构
  - `src/pages/mine/mine.vue` — 个人中心 UI 改版
  - `src/pages/order/order.vue` — 订单列表与状态展示重构
- **后端**
  - 无变更（无 API 行为或业务逻辑改动）
- **数据**
  - 无变更，不涉及数据库迁移
