<template>
  <scroll-view scroll-y class="page-wrap" :show-scrollbar="false" :style="{ height: pageHeight }">
    <!-- Banner Section -->
    <view class="banner-section">
      <uv-swiper
        v-if="listAds.length"
        class="bg-swiper"
        height="460"
        imgMode="aspectFill"
        keyName="image"
        :list="listAds"
        indicatorMode="dot"
        indicatorStyle="bottom"
      ></uv-swiper>
      <view v-else class="bg-swiper-fallback">
        <image src="/static/images/banners/home-banner.png" mode="aspectFill" class="fallback-img"></image>
      </view>
      
      <!-- Text Overlay -->
      <view class="banner-overlay-text">
        <view class="title-line">极客精酿</view>
        <view class="subtitle-line">每日新鲜送达</view>
      </view>
    </view>

    <!-- Main Content Container -->
    <view class="content">
      <!-- 3-Card Navigation Grid -->
      <view class="nav-grid">
        <!-- Card 1: Large (Takeout) -->
        <view class="nav-card large" @tap="takeout">
          <view class="card-icon-wrap">
            <svg class="nav-svg-icon" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="38" cy="18" r="4" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M30 26L36 22L42 27L38 35H30" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M18 42H44L38 34" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <circle cx="20" cy="48" r="6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <circle cx="44" cy="48" r="6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M44 48L46 32H42" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <rect x="12" y="24" width="12" height="14" rx="2" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M4 22H8M2 28H8M4 34H6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </view>
          <view class="card-info">
            <view class="card-title">极客精酿</view>
            <view class="card-sub">每日新鲜贵</view>
          </view>
        </view>

        <!-- Card 2: Medium (Takeout Fast) -->
        <view class="nav-card small" @tap="takeout">
          <view class="card-icon-wrap">
            <svg class="nav-svg-icon" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M22 42H48L42 34" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <circle cx="24" cy="48" r="5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <circle cx="46" cy="48" r="5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M46 48L48 30H44" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <rect x="14" y="26" width="10" height="12" rx="1.5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M6 18H14M4 26H12M8 34H12" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </view>
          <view class="card-info">
            <view class="card-title">极速外卖</view>
            <view class="card-sub">30分钟冷链送达</view>
          </view>
        </view>

        <!-- Card 3: Medium (Takein Store) -->
        <view class="nav-card small" @tap="takein">
          <view class="card-icon-wrap">
            <svg class="nav-svg-icon" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 22H52" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round"/>
              <path d="M14 22L18 12H46L50 22" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M12 22C14 22 15 24 17 24C19 24 20 22 22 22C24 22 25 24 27 24C29 24 30 22 32 22C34 22 35 24 37 24C39 24 40 22 42 22C44 22 45 24 47 24C49 24 50 22 52 22" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round"/>
              <path d="M16 24V52H48V24" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M26 52V36H38V52" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <rect x="24" y="14" width="16" height="5" rx="1" fill="#D4AF37"/>
            </svg>
          </view>
          <view class="card-info">
            <view class="card-title">到店自取</view>
            <view class="card-sub">下单免排队</view>
          </view>
        </view>
      </view>

      <!-- Stats Bar (会员积分 / 账户余额 / 可用卡券) -->
      <view class="stats-bar">
        <view class="stat-item">
          <text class="label">会员积分：</text>
          <text class="value">{{ isLogin ? (member.point || 0) : 0 }}</text>
        </view>
        <view class="divider"></view>
        <view class="stat-item">
          <text class="label">账户余额：</text>
          <text class="value">¥{{ isLogin ? parseFloat(member.balance || 0).toFixed(2) : '0.00' }}</text>
        </view>
        <view class="divider"></view>
        <view class="stat-item" @tap="coupons">
          <text class="label">可用卡券：</text>
          <text class="value">{{ isLogin ? (member.couponCount || 0) : 0 }}张</text>
        </view>
      </view>

      <!-- Stamp Card (集满8杯赠送精酿一杯) -->
      <view class="stamp-card">
        <view class="stamp-header">
          <view class="stamp-title">集满8杯赠送精酿一杯 <text class="stamp-count-text">({{ isLogin ? Math.min(member.point || 0, 8) : 0 }}/8)</text></view>
        </view>
        <view class="stamp-grid">
          <view
            v-for="i in 7"
            :key="i"
            class="stamp-item"
            :class="{ active: isLogin && (member.point || 0) >= i }"
          >
            <!-- Custom Beer Glass SVG -->
            <svg class="beer-svg" viewBox="0 0 24 30" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path class="glass-body" d="M6 8V24C6 25.1 6.9 26 8 26H16C17.1 26 18 25.1 18 24V8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path class="glass-handle" d="M18 11H20.5C21.3 11 22 11.7 22 12.5V19.5C22 20.3 21.3 21 20.5 21H18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path class="beer-foam" d="M5 8C5 6.9 5.9 6 7 6H17C18.1 6 19 6.9 19 8C19 8.55 18.55 9 18 9H6C5.45 9 5 8.55 5 8Z" fill="currentColor" />
              <path class="beer-fill" d="M7 10V24H17V10H7Z" fill="currentColor"/>
            </svg>
          </view>
        </view>
      </view>

      <!-- Bottom Services Grid -->
      <view class="services-grid">
        <view class="grid-item" @tap="coupons">
          <view class="icon-wrap">
            <svg class="grid-icon" viewBox="0 0 24 24" fill="none" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2 9V6a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v3a2 2 0 0 0 0 4v3a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-3a2 2 0 0 0 0-4Z" />
              <path d="M12 4v16" stroke-dasharray="2 2" />
            </svg>
          </view>
          <view class="grid-label">卡券中心</view>
        </view>
        <view class="grid-item" @tap="goScore">
          <view class="icon-wrap">
            <svg class="grid-icon" viewBox="0 0 24 24" fill="none" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="8" r="6" />
              <path d="M12 14c-4.4 0-8 2-8 4v2h16v-2c0-2-3.6-4-8-4Z" />
              <path d="M9 8h6M12 5v6" />
            </svg>
          </view>
          <view class="grid-label">积分商城</view>
        </view>
        <view class="grid-item" @tap="inviteFriend">
          <view class="icon-wrap">
            <svg class="grid-icon" viewBox="0 0 24 24" fill="none" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 12v10H4V12" />
              <rect x="2" y="7" width="20" height="5" rx="1" />
              <path d="M12 22V7" />
              <path d="M12 7c-1.5-3-4.5-3-4.5 0S10.5 7 12 7Z" />
              <path d="M12 7c1.5-3 4.5-3 4.5 0S13.5 7 12 7Z" />
            </svg>
          </view>
          <view class="grid-label">邀请有礼</view>
        </view>
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
const inviteFriend = () => {
  uni.showToast({ title: '功能开发中', icon: 'none' })
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
page {
  background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
.page-wrap {
  background-color: #121212;
  box-sizing: border-box;
}

/* ---- Banner Section ---- */
.banner-section {
  position: relative;
  width: 100%;
  height: 460rpx;
  overflow: hidden;

  .bg-swiper {
    width: 100%;
    height: 100%;
  }

  .bg-swiper-fallback {
    width: 100%;
    height: 100%;
    .fallback-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(0,0,0,0) 40%, rgba(18,18,18,1) 100%);
    pointer-events: none;
    z-index: 1;
  }

  .banner-overlay-text {
    position: absolute;
    left: 40rpx;
    bottom: 50rpx;
    z-index: 2;

    .title-line {
      font-size: 58rpx;
      font-weight: 800;
      color: #F5D061;
      letter-spacing: 4rpx;
      text-shadow: 0 4rpx 16rpx rgba(0,0,0,0.8);
      margin-bottom: 6rpx;
    }
    .subtitle-line {
      font-size: 50rpx;
      font-weight: 700;
      color: #F5D061;
      letter-spacing: 4rpx;
      text-shadow: 0 4rpx 16rpx rgba(0,0,0,0.8);
    }
  }
}

/* ---- Content ---- */
.content {
  padding: 0 30rpx 40rpx;
  margin-top: -10rpx;
  position: relative;
  z-index: 2;
}

/* ---- 3-Card Navigation Grid ---- */
.nav-grid {
  display: flex;
  justify-content: space-between;
  margin-bottom: 30rpx;
  gap: 16rpx;
}

.nav-card {
  background-color: #1E1E1E;
  border: 1rpx solid rgba(212, 175, 55, 0.15);
  border-radius: 16rpx;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: 0 8rpx 24rpx rgba(0,0,0,0.3);
  transition: all 0.2s ease;
  padding: 24rpx 16rpx;
  
  &:active {
    transform: scale(0.97);
    border-color: rgba(212, 175, 55, 0.4);
  }

  &.large {
    width: 48%;
  }

  &.small {
    width: 24%;
    .card-title {
      font-size: 26rpx;
    }
    .card-sub {
      font-size: 16rpx;
      white-space: nowrap;
    }
  }

  .card-icon-wrap {
    width: 80rpx;
    height: 80rpx;
    margin-bottom: 12rpx;
    display: flex;
    justify-content: center;
    align-items: center;

    .nav-svg-icon {
      width: 100%;
      height: 100%;
    }
  }

  .card-info {
    text-align: center;
  }

  .card-title {
    font-size: 30rpx;
    font-weight: bold;
    color: #F5D061;
    margin-bottom: 4rpx;
  }

  .card-sub {
    font-size: 20rpx;
    color: #9E9E9E;
  }
}

/* ---- Stats Bar ---- */
.stats-bar {
  background: rgba(30, 30, 30, 0.9);
  border: 1rpx solid rgba(212, 175, 55, 0.15);
  border-radius: 40rpx;
  padding: 24rpx 30rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.4);

  .stat-item {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 24rpx;

    .label {
      color: #9E9E9E;
    }

    .value {
      color: #F5D061;
      font-weight: bold;
      margin-left: 4rpx;
    }
  }

  .divider {
    width: 1rpx;
    height: 30rpx;
    background-color: rgba(255, 255, 255, 0.1);
  }
}

/* ---- Stamp Card ---- */
.stamp-card {
  background-color: #1E1E1E;
  border: 1rpx solid rgba(212, 175, 55, 0.15);
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 8rpx 24rpx rgba(0,0,0,0.3);

  .stamp-header {
    margin-bottom: 24rpx;
    
    .stamp-title {
      font-size: 28rpx;
      font-weight: bold;
      color: #FFFFFF;
    }
    
    .stamp-count-text {
      color: #F5D061;
      margin-left: 8rpx;
    }
  }

  .stamp-grid {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .stamp-item {
    display: flex;
    justify-content: center;
    align-items: center;

    .beer-svg {
      width: 56rpx;
      height: 70rpx;
      
      .glass-body, .glass-handle {
        color: rgba(255, 255, 255, 0.15);
      }
      
      .beer-fill, .beer-foam {
        color: transparent;
      }
    }

    &.active {
      .beer-svg {
        .glass-body, .glass-handle {
          color: #D4AF37;
        }
        .beer-fill {
          color: #D4AF37;
        }
        .beer-foam {
          color: #FFFFFF;
        }
      }
    }
  }
}

/* ---- Services Grid ---- */
.services-grid {
  display: flex;
  background-color: #1E1E1E;
  border: 1rpx solid rgba(255, 255, 255, 0.05);
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 24rpx rgba(0,0,0,0.3);

  .grid-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 36rpx 20rpx;
    border-right: 1rpx solid rgba(255, 255, 255, 0.05);
    transition: all 0.2s ease;
    
    &:last-child {
      border-right: none;
    }

    &:active {
      background-color: rgba(255, 255, 255, 0.02);
    }

    .icon-wrap {
      width: 52rpx;
      height: 52rpx;
      margin-bottom: 12rpx;
      display: flex;
      justify-content: center;
      align-items: center;

      .grid-icon {
        width: 100%;
        height: 100%;
      }
    }

    .grid-label {
      font-size: 24rpx;
      color: #FFFFFF;
      font-weight: 500;
    }
  }
}
</style>
