<template>
  <scroll-view scroll-y class="page-wrap" :style="{ height: pageHeight }">
    <view class="banner">
      <uv-swiper
        v-if="listAds.length"
        class="bg"
        height="320"
        imgMode="aspectFill"
        keyName="image"
        :list="listAds"
        indicatorMode="dot"
        indicatorStyle="bottom"
      ></uv-swiper>
      <view class="intro">
        <view class="greet">您好，{{ isLogin ? member.nickname : '游客' }}</view>
        <view class="note">极客精酿 · 每日新鲜送达</view>
      </view>
    </view>

    <view class="content">
      <!-- 自取 / 外卖 -->
      <view class="flex justify-between yshop-menu">
        <view class="flex flex-column align-center yshop-menu-item" @tap="takein">
          <image src="/static/images/index002.png" mode="aspectFit" class="img-01"></image>
          <view class="menu-title">自取</view>
          <view class="menu-sub">下单免排队</view>
        </view>
        <view class="flex flex-column align-center yshop-menu-item" @tap="takeout">
          <image src="/static/images/index003.png" mode="aspectFit" class="img-01"></image>
          <view class="menu-title">外卖</view>
          <view class="menu-sub">精酿送到家</view>
        </view>
      </view>

      <!-- 集点卡 -->
      <view class="info stamp-card">
        <view class="stamp-header flex justify-between align-center">
          <view class="stamp-title-wrap">
            <view class="stamp-title">精酿集点卡</view>
            <view class="stamp-sub">每消费1杯积1点，集满8点兑换1杯</view>
          </view>
          <view class="stamp-count">
            已集 <text class="highlight">{{ member.point || 0 }}</text> / 8
          </view>
        </view>
        <view class="stamp-grid">
          <view
            v-for="i in 8"
            :key="i"
            class="stamp-item"
            :class="{ active: (member.point || 0) >= i }"
          >
            <view class="stamp-glass">
              <view class="beer-liquid" :style="{ height: (member.point || 0) >= i ? '70%' : '0%' }"></view>
              <view class="beer-foam"></view>
            </view>
            <view class="stamp-num">{{ i }}</view>
          </view>
        </view>
      </view>

      <!-- 我的卡券 -->
      <view class="info info-row" @tap="coupons">
        <view class="info-left">
          <view class="info-title">我的卡券</view>
          <view class="info-count">{{ member.couponCount }}</view>
          <view class="info-desc">可抵扣商品价格哦</view>
        </view>
        <view class="action-btn" @tap="coupons">去领个券</view>
      </view>

      <!-- 积分商城 -->
      <view class="info info-row" @tap="goScore">
        <view class="info-left">
          <view class="info-title">积分商城</view>
          <view class="info-desc">进入积分商城兑换精酿周边及超值好礼</view>
        </view>
        <view class="action-btn outline" @tap="goScore">逛一逛</view>
      </view>
    </view>
  </scroll-view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { menuAds } from '@/api/market'
import { userGetUserInfo } from '@/api/user'
import { storeToRefs } from 'pinia'
import { useMainStore } from '@/store/store'

const main = useMainStore()
const { member, store, isLogin } = storeToRefs(main)
const listAds = ref([])

// 计算不含tabBar的页面高度
const pageHeight = ref('100vh')
onMounted(() => {
  const info = uni.getSystemInfoSync()
  // tabBar 高度通常 50px + 底部安全区
  const safeAreaBottom = info.safeAreaInsets ? info.safeAreaInsets.bottom : 0
  const tabBarHeight = 50 + safeAreaBottom
  pageHeight.value = `calc(100vh - ${tabBarHeight}px)`
})

const handGetListAds = async () => {
  let shop_id = store.value.id ? store.value.id : 0
  let data = await menuAds({ shop_id })
  if (data) {
    listAds.value = data.list
    uni.setStorage({ key: 'isActive', data: data.isActive })
    if (data.list.length > 0) {
      uni.setStorage({ key: 'shopAd', data: data.list[0].image })
    }
  }
}

const takein = () => {
  main.SET_ORDER_TYPE('takein')
  uni.switchTab({ url: '/pages/menu/menu' })
}
const takeout = () => {
  main.SET_ORDER_TYPE('takeout')
  uni.switchTab({ url: '/pages/menu/menu' })
}
const coupons = () => {
  if (!main.isLogin) {
    uni.navigateTo({ url: '/pages/components/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/components/pages/coupons/coupons' })
}
const goScore = () => {
  uni.navigateTo({ url: '/pages/components/pages/scoreproduct/list' })
}

const getUserInfo = async () => {
  if (isLogin.value) {
    const data = await userGetUserInfo()
    if (data) main.SET_MEMBER(data)
  }
}

onLoad(() => { handGetListAds() })
onShow(() => { getUserInfo() })
</script>

<style lang="scss">
/* 全局覆盖页面背景 */
page {
  background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
.page-wrap {
  background-color: #121212;
  box-sizing: border-box;
}

/* ---- Banner ---- */
.banner {
  position: relative;
  width: 100%;

  .bg {
    display: block;
    width: 100%;
  }

  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(0,0,0,0.05) 0%, rgba(18,18,18,0.7) 100%);
    pointer-events: none;
  }

  .intro {
    position: absolute;
    top: 40rpx;
    left: 40rpx;
    z-index: 2;

    .greet {
      font-size: 36rpx;
      font-weight: bold;
      color: #D4AF37;
      margin-bottom: 8rpx;
    }
    .note {
      font-size: 24rpx;
      color: #FFFFFF;
      letter-spacing: 2rpx;
      opacity: 0.9;
    }
  }
}

/* ---- Content ---- */
.content {
  padding: 20rpx 25rpx 30rpx;
}

/* ---- 自取/外卖 ---- */
.yshop-menu {
  margin-bottom: 20rpx;
  gap: 20rpx;
}
.yshop-menu-item {
  flex: 1;
  background-color: #1E1E1E;
  border: 1rpx solid rgba(212, 175, 55, 0.15);
  border-radius: 16rpx;
  padding: 30rpx 0;
  align-items: center;
  transition: all 0.2s ease;
  &:active { transform: scale(0.97); }

  .img-01 {
    width: 90rpx;
    height: 90rpx;
    margin-bottom: 12rpx;
  }
  .menu-title {
    font-size: 30rpx;
    font-weight: bold;
    color: #D4AF37;
    margin-bottom: 6rpx;
  }
  .menu-sub {
    font-size: 22rpx;
    color: #9E9E9E;
  }
}

/* ---- Info Cards ---- */
.info {
  background-color: #1E1E1E;
  border: 1rpx solid rgba(255,255,255,0.05);
  border-radius: 16rpx;
  margin-bottom: 20rpx;
  padding: 25rpx 25rpx;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.2);
}

/* ---- Stamp Card ---- */
.stamp-card {
  display: flex;
  flex-direction: column;
  border-color: rgba(212, 175, 55, 0.2);
}

.stamp-header {
  margin-bottom: 20rpx;
  .stamp-title-wrap {
    .stamp-title {
      font-size: 28rpx;
      font-weight: bold;
      color: #D4AF37;
    }
    .stamp-sub {
      font-size: 20rpx;
      color: #9E9E9E;
      margin-top: 4rpx;
    }
  }
  .stamp-count {
    font-size: 22rpx;
    color: #FFFFFF;
    .highlight {
      font-size: 30rpx;
      font-weight: bold;
      color: #D4AF37;
    }
  }
}

.stamp-grid {
  display: flex;
  justify-content: space-between;
}
.stamp-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 70rpx;

  .stamp-glass {
    width: 44rpx;
    height: 56rpx;
    border: 2rpx solid rgba(255,255,255,0.25);
    border-radius: 4rpx 4rpx 8rpx 8rpx;
    position: relative;
    overflow: hidden;
    background: rgba(255,255,255,0.03);
    &::after {
      content: '';
      position: absolute;
      right: -8rpx;
      top: 12rpx;
      width: 10rpx;
      height: 22rpx;
      border: 2rpx solid rgba(255,255,255,0.25);
      border-left: none;
      border-radius: 0 4rpx 4rpx 0;
    }
  }
  .beer-liquid {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: linear-gradient(0deg, #B27A17 0%, #D4AF37 100%);
    transition: height 0.5s ease;
    z-index: 1;
  }
  .beer-foam {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 8rpx;
    background: #FFF;
    opacity: 0;
    z-index: 2;
    border-radius: 4rpx 4rpx 0 0;
    transition: opacity 0.3s;
  }
  .stamp-num {
    font-size: 18rpx;
    color: #9E9E9E;
    margin-top: 8rpx;
  }

  &.active {
    .stamp-glass {
      border-color: #D4AF37;
      box-shadow: 0 0 8rpx rgba(212, 175, 55, 0.4);
      &::after { border-color: #D4AF37; }
    }
    .beer-foam { opacity: 0.85; }
    .stamp-num { color: #D4AF37; font-weight: bold; }
  }
}

/* ---- 卡券/积分 行 ---- */
.info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.info-left {
  flex: 1;
  .info-title {
    font-size: 28rpx;
    font-weight: bold;
    color: #FFFFFF;
  }
  .info-count {
    font-size: 48rpx;
    font-weight: bold;
    color: #D4AF37;
    line-height: 1.2;
    margin: 4rpx 0;
  }
  .info-desc {
    font-size: 22rpx;
    color: #9E9E9E;
  }
}

.action-btn {
  background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
  color: #121212;
  font-weight: bold;
  font-size: 24rpx;
  padding: 14rpx 32rpx;
  border-radius: 30rpx;
  box-shadow: 0 4rpx 12rpx rgba(212,175,55,0.3);
  white-space: nowrap;
  flex-shrink: 0;

  &.outline {
    background: transparent;
    color: #D4AF37;
    border: 2rpx solid #D4AF37;
    box-shadow: none;
  }
}
</style>
