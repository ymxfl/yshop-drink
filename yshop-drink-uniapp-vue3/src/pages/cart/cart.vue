<template>
  <view class="cart-page">
    <!-- Header -->
    <view class="cart-header">
      <view class="header-title">购物车</view>
      <view class="header-count" v-if="cart.length > 0">共 {{ getCartGoodsNumber }} 件</view>
      <view class="clear-btn" v-if="cart.length > 0" @tap="handleCartClear">清空</view>
    </view>

    <!-- Empty -->
    <view class="empty-wrap" v-if="cart.length == 0">
      <view class="empty-icon">🍺</view>
      <view class="empty-text">购物车空空如也</view>
      <view class="empty-sub">去点餐页面添加精酿好物吧</view>
      <view class="go-order-btn" @tap="goMenu">去点餐</view>
    </view>

    <!-- Cart List -->
    <scroll-view scroll-y class="cart-list" v-if="cart.length > 0">
      <view class="cart-item" v-for="(item, index) in cart" :key="index">
        <view class="item-info">
          <view class="item-name">{{ item.name }}</view>
          <view class="item-spec" v-if="item.valueStr">{{ item.valueStr }}</view>
          <view class="item-price">¥{{ item.price }}</view>
        </view>
        <view class="item-actions">
          <view class="qty-btn minus" @tap="handleCartItemReduce(index)">−</view>
          <view class="qty-num">{{ item.number }}</view>
          <view class="qty-btn plus" @tap="handleCartItemAdd(index)">+</view>
        </view>
      </view>
    </scroll-view>

    <!-- Bottom Bar -->
    <view class="cart-bottom" v-if="cart.length > 0">
      <view class="total-wrap">
        <view class="total-label">应付金额</view>
        <view class="total-amount">¥{{ getCartGoodsPrice }}</view>
      </view>
      <view class="pay-btn" @tap="toPay">去结算</view>
    </view>

    <uv-toast ref="uToast"></uv-toast>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onShow } from '@dcloudio/uni-app'

const main = useMainStore()
const { orderType, store, isLogin } = storeToRefs(main)
const cart = ref([])
const uToast = ref()

onShow(() => {
  cart.value = uni.getStorageSync('cart') || []
})

const getCartGoodsNumber = computed(() => {
  return cart.value.reduce((acc, cur) => acc + cur.number, 0)
})
const getCartGoodsPrice = computed(() => {
  const price = cart.value.reduce((acc, cur) => acc + cur.number * cur.price, 0)
  return parseFloat(price).toFixed(2)
})

const handleCartItemAdd = (index) => {
  cart.value[index].number += 1
  uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const handleCartItemReduce = (index) => {
  if (cart.value[index].number === 1) {
    cart.value.splice(index, 1)
  } else {
    cart.value[index].number -= 1
  }
  uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const handleCartClear = () => {
  uni.showModal({
    title: '提示',
    content: '确定清空购物车么',
    success: ({ confirm }) => {
      if (confirm) {
        cart.value = []
        uni.setStorageSync('cart', [])
      }
    }
  })
}
const goMenu = () => {
  uni.switchTab({ url: '/pages/menu/menu' })
}
const toPay = () => {
  if (cart.value.length == 0) {
    uToast.value.show({ message: '请先去点餐哦', type: 'error' })
    return
  }
  if (!isLogin.value) {
    uni.navigateTo({ url: '/pages/components/pages/login/login' })
    return
  }
  if (store.value.status == 0) {
    uToast.value.show({ message: '不在店铺营业时间内', type: 'error' })
    return
  }
  uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
  uni.navigateTo({ url: '/pages/components/pages/pay/pay' })
}
</script>

<style lang="scss">
page {
  background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
.cart-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #121212;
}

/* Header */
.cart-header {
  display: flex;
  align-items: center;
  padding: 60rpx 30rpx 20rpx;
  background-color: #1E1E1E;
  border-bottom: 1rpx solid rgba(255,255,255,0.05);

  .header-title {
    font-size: 36rpx;
    font-weight: bold;
    color: #FFFFFF;
    flex: 1;
  }
  .header-count {
    font-size: 24rpx;
    color: #9E9E9E;
    margin-right: 20rpx;
  }
  .clear-btn {
    font-size: 24rpx;
    color: #D4AF37;
    padding: 8rpx 20rpx;
    border: 1rpx solid rgba(212,175,55,0.4);
    border-radius: 20rpx;
    &:active { opacity: 0.7; }
  }
}

/* Empty */
.empty-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-bottom: 100rpx;

  .empty-icon {
    font-size: 80rpx;
    margin-bottom: 24rpx;
    opacity: 0.6;
  }
  .empty-text {
    font-size: 32rpx;
    font-weight: bold;
    color: #FFFFFF;
    margin-bottom: 12rpx;
  }
  .empty-sub {
    font-size: 24rpx;
    color: #9E9E9E;
    margin-bottom: 40rpx;
  }
  .go-order-btn {
    background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
    color: #121212;
    font-weight: bold;
    font-size: 28rpx;
    padding: 18rpx 60rpx;
    border-radius: 40rpx;
    &:active { transform: scale(0.97); }
  }
}

/* Cart List */
.cart-list {
  flex: 1;
  overflow: hidden;
  padding: 0 25rpx;
  padding-bottom: 20rpx;
}

.cart-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #1E1E1E;
  border-radius: 16rpx;
  padding: 24rpx 24rpx;
  margin-top: 20rpx;
  border: 1rpx solid rgba(255,255,255,0.05);

  .item-info {
    flex: 1;
    margin-right: 20rpx;
    overflow: hidden;

    .item-name {
      font-size: 28rpx;
      font-weight: bold;
      color: #FFFFFF;
      margin-bottom: 8rpx;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .item-spec {
      font-size: 22rpx;
      color: #9E9E9E;
      margin-bottom: 8rpx;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .item-price {
      font-size: 30rpx;
      font-weight: bold;
      color: #D4AF37;
    }
  }

  .item-actions {
    display: flex;
    align-items: center;
    gap: 16rpx;
    flex-shrink: 0;

    .qty-btn {
      width: 52rpx;
      height: 52rpx;
      border-radius: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32rpx;
      font-weight: bold;
      transition: all 0.15s ease;
      &:active { transform: scale(0.9); }
      &.minus {
        background-color: rgba(255,255,255,0.08);
        color: #FFFFFF;
        border: 1rpx solid rgba(255,255,255,0.15);
      }
      &.plus {
        background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
        color: #121212;
      }
    }
    .qty-num {
      font-size: 30rpx;
      font-weight: bold;
      color: #FFFFFF;
      min-width: 40rpx;
      text-align: center;
    }
  }
}

/* Bottom Bar */
.cart-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background-color: #1E1E1E;
  border-top: 1rpx solid rgba(212,175,55,0.3);
  box-shadow: 0 -4rpx 20rpx rgba(0,0,0,0.4);

  .total-wrap {
    display: flex;
    flex-direction: column;
    .total-label {
      font-size: 22rpx;
      color: #9E9E9E;
    }
    .total-amount {
      font-size: 44rpx;
      font-weight: bold;
      color: #D4AF37;
    }
  }

  .pay-btn {
    background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
    color: #121212;
    font-weight: bold;
    font-size: 32rpx;
    padding: 22rpx 70rpx;
    border-radius: 50rpx;
    box-shadow: 0 4rpx 20rpx rgba(212,175,55,0.35);
    transition: all 0.2s ease;
    &:active { transform: scale(0.97); }
  }
}
</style>
