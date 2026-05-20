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
            <image class="nav-svg-icon" :src="takeoutLargeIcon" mode="aspectFit"></image>
          </view>
          <view class="card-info">
            <view class="card-title">极客精酿</view>
            <view class="card-sub">每日新鲜贵</view>
          </view>
        </view>

        <!-- Card 2: Medium (Takeout Fast) -->
        <view class="nav-card small" @tap="takeout">
          <view class="card-icon-wrap">
            <image class="nav-svg-icon" :src="takeoutSmallIcon" mode="aspectFit"></image>
          </view>
          <view class="card-info">
            <view class="card-title">极速外卖</view>
            <view class="card-sub">30分钟冷链送达</view>
          </view>
        </view>

        <!-- Card 3: Medium (Takein Store) -->
        <view class="nav-card small" @tap="takein">
          <view class="card-icon-wrap">
            <image class="nav-svg-icon" :src="takeinSmallIcon" mode="aspectFit"></image>
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
          <!-- Coins SVG -->
          <image class="stat-icon" :src="statCoinIcon" mode="aspectFit" style="width: 28rpx; height: 28rpx; margin-right: 8rpx;"></image>
          <text class="label">会员积分：</text>
          <text class="value">{{ isLogin ? (member.integral || 0) : 0 }}</text>
        </view>
        <view class="divider"></view>
        <view class="stat-item">
          <!-- Wallet SVG -->
          <image class="stat-icon" :src="statWalletIcon" mode="aspectFit" style="width: 28rpx; height: 28rpx; margin-right: 8rpx;"></image>
          <text class="label">账户余额：</text>
          <text class="value">¥{{ isLogin ? parseFloat(member.nowMoney || 0).toFixed(2) : '0.00' }}</text>
        </view>
        <view class="divider"></view>
        <view class="stat-item" @tap="coupons">
          <!-- Ticket SVG -->
          <image class="stat-icon" :src="statTicketIcon" mode="aspectFit" style="width: 28rpx; height: 28rpx; margin-right: 8rpx;"></image>
          <text class="label">可用卡券：</text>
          <text class="value">{{ isLogin ? (member.couponCount || 0) : 0 }}张</text>
        </view>
      </view>

      <!-- Stamp Card (集满8杯赠送精酿一杯) -->
      <view class="stamp-card">
        <view class="stamp-header">
          <view class="stamp-title">集满8杯赠送精酿一杯 <text class="stamp-count-text">({{ isLogin ? Math.min(member.point || member.payCount || 0, 8) : 0 }}/8)</text></view>
        </view>
        <view class="stamp-grid">
          <view
            v-for="i in 8"
            :key="i"
            class="stamp-item"
          >
            <!-- Custom Beer Glass Image switching between active and inactive -->
            <image
              class="beer-glass-icon"
              :src="(isLogin && (member.point || member.payCount || 0) >= i) ? beerGlassActiveIcon : beerGlassInactiveIcon"
              mode="aspectFit"
            ></image>
          </view>
        </view>
      </view>

      <!-- Bottom Services Grid (Only Coupons, Score Product, Invite Friend) -->
      <view class="services-grid">
        <view class="grid-item" @tap="coupons">
          <view class="icon-wrap">
            <image class="grid-icon" :src="gridCouponsIcon" mode="aspectFit"></image>
          </view>
          <view class="grid-label">卡券中心</view>
        </view>
        <view class="grid-item" @tap="goScore">
          <view class="icon-wrap">
            <image class="grid-icon" :src="gridScoreIcon" mode="aspectFit"></image>
          </view>
          <view class="grid-label">积分商城</view>
        </view>
        <view class="grid-item" @tap="inviteFriend">
          <view class="icon-wrap">
            <image class="grid-icon" :src="gridInviteIcon" mode="aspectFit"></image>
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

// Base64 Encoded SVG Icons for WeChat Mini Program compatibility
const takeoutLargeIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNjQgNjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxjaXJjbGUgY3g9IjM4IiBjeT0iMTgiIHI9IjQiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNMzAgMjZMMzYgMjJMNDIgMjdMMzggMzVIMzAiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNMTggNDJINDRMMzggMzQiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8Y2lyY2xlIGN4PSIyMCIgY3k9IjQ4IiByPSI2IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMi41IiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPGNpcmNsZSBjeD0iNDQiIGN5PSI0OCIgcj0iNiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik00NCA0OEw0NiAzMkg0MiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxyZWN0IHg9IjEyIiB5PSIyNCIgd2lkdGg9IjEyIiBoZWlnaHQ9IjE0IiByeD0iMiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik00IDIySDhNMiAyOEg4TTQgMzRINiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDwvc3ZnPg=="
const takeoutSmallIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNjQgNjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik0yMiA0Mkg0OEw0MiAzNCIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxjaXJjbGUgY3g9IjI0IiBjeT0iNDgiIHI9IjUiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8Y2lyY2xlIGN4PSI0NiIgY3k9IjQ4IiByPSI1IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMi41IiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHBhdGggZD0iTTQ2IDQ4TDQ4IDMwSDQ0IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMi41IiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHJlY3QgeD0iMTQiIHk9IjI2IiB3aWR0aD0iMTAiIGhlaWdodD0iMTIiIHJ4PSIxLjUiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNNiAxOEgxNE00IDI2SDEyTTggMzRIMTIiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8L3N2Zz4="
const takeinSmallIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNjQgNjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik0xMiAyMkg1MiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+IDxwYXRoIGQ9Ik0xNCAyMkwxOCAxMkg0Nkw1MCAyMiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik0xMiAyMkMxNCAyMiAxNSAyNCAxNyAyNEMxOSAyNCAyMCAyMiAyMiAyMkMyNCAyMiAyNSAyNCAyNyAyNEMyOSAyNCAzMCAyMiAzMiAyMkMzNCAyMiAzNSAyNCAzNyAyNEMzOSAyNCA0MCAyMiA0MiAyMkM0NCAyMiA0NSAyNCA0NyAyNEMzOSAyNCA1MCAyMiA1MiAyMiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+IDxwYXRoIGQ9Ik0xNiAyNFY1Mkg0OFYyNCIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik0yNiA1MlYzNkgzOFY1MiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxyZWN0IHg9IjI0IiB5PSIxNCIgd2lkdGg9IjE2IiBoZWlnaHQ9IjUiIHJ4PSIxIiBmaWxsPSIjRDRBRjM3Ii8+IDwvc3ZnPg=="
const statCoinIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjgiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPGxpbmUgeDE9IjEyIiB5MT0iOCIgeDI9IjEyIiB5Mj0iMTYiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPGxpbmUgeDE9IjgiIHkxPSIxMiIgeDI9IjE2IiB5Mj0iMTIiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPC9zdmc+"
const statWalletIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxyZWN0IHg9IjIiIHk9IjQiIHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIgcng9IjIiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHBhdGggZD0iTTEyIDExaDh2MmgtOHoiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPC9zdmc+"
const statTicketIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik0xNSA0SDlNMTUgMjBIOU0yMCA5djZNNCA5djYiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHJlY3QgeD0iMiIgeT0iNCIgd2lkdGg9IjIwIiBoZWlnaHQ9IjE2IiByeD0iMiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8L3N2Zz4="
const beerGlassInactiveIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMzAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik02IDhWMjRDNiAyNS4xIDYuOSAyNiA4IDI2SDE2QzE3LjEgMjYgMTggMjUuMSAxOCAyNFY4IiBzdHJva2U9IiMzMzMzMzMiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik0xOCAxMUgyMC41QzIxLjMgMTEgMjIgMTEuNyAyMiAxMi41VjE5LjVDMjIgMjAuMyAyMS4zIDIxIDIwLjUgMjFIMTgiIHN0cm9rZT0iIzMzMzMzMyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPC9zdmc+"
const beerGlassActiveIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMzAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik02IDhWMjRDNiAyNS4xIDYuOSAyNiA4IDI2SDE2QzE3LjEgMjYgMTggMjUuMSAxOCAyNFY4IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZT0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik0xOCAxMUgyMC41QzIxLjMgMTEgMjIgMTEuNyAyMiAxMi41VjE5LjVDMjIgMjAuMyAyMS4zIDIxIDIwLjUgMjFIMTgiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHBhdGggZD0iTTUgOEM1IDYuOSA1LjkgNiA3IDZIMTdDMTguMSA2IDE5IDYuOSAxOSA4QzE5IDguNTUgMTguNTUgOSAxOCA5SDZDNS40NSA5IDUgOC41NSA1IDhaIiBmaWxsPSIjRkZGRkZGIi8+IDxwYXRoIGQ9Ik03IDEwVjI0SDE3VjEwSDdaIiBmaWxsPSIjRDRBRjM3Ii8+IDwvc3ZnPg=="
const gridCouponsIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik0yIDlWNmEyIDIgMCAwIDEgMi0yaDE2YTIgMiAwIDAgMSAyIDJ2M2EyIDIgMCAwIDAgMCA0djNhMiAyIDAgMCAxLTIgMkg0YTIgMiAwIDAgMS0yLTJ2LTNhMiAyIDAgMCAwIDAtNFoiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4gPHBhdGggZD0iTTEyIDR2MTYiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1kYXNoYXJyYXk9IjIgMiIgLz4gPC9zdmc+"
const gridScoreIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxjaXJjbGUgY3g9IjEyIiBjeT0iOCIgcj0iNiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNMTIgMTRjLTQuNCAwLTggMi04IDR2MmgxNnYtMmMwLTItMy42LTQtOC00WiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNOSA4aDZNMTIgNXY2IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZT0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDwvc3ZnPg=="
const gridInviteIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+IDxwYXRoIGQ9Ik0yMCAxMnYxMEg0VjEyIiBzdHJva2U9IiNENEFGMzciIHN0cm9rZT0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxyZWN0IHg9IjIiIHk9IjciIHdpZHRoPSIyMCIgaGVpZ2h0PSI1IiByeD0iMSIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNMTIgMjJWNyIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8cGF0aCBkPSJNMTIgN2MtMS41LTMtNC41LTMtNC41IDBTMTAuNSA3IDEyIDdaIiBzdHJva2U9IiNENEFGMzciIHN0cm9rZT0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+IDxwYXRoIGQ9Ik0xMiA3YzEuNS0zIDQuNS0zIDQuNSAwUzEzLjUgNyAxMiA3WiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPiA8L3N2Zz4="

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
const goAddress = () => {
  if (!main.isLogin) {
    uni.navigateTo({ url: '/pages/components/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/components/pages/address/address' })
}
const goOrders = () => {
  if (!main.isLogin) {
    uni.navigateTo({ url: '/pages/components/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/components/pages/orders/orders' })
}
const goCustomer = () => {
  uni.makePhoneCall({ phoneNumber: '18888888888' })
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

    .beer-glass-icon {
      width: 56rpx;
      height: 70rpx;
    }
  }
}

/* ---- Services Grid ---- */
.services-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  background-color: #1E1E1E;
  border: 1rpx solid rgba(255, 255, 255, 0.05);
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 24rpx rgba(0,0,0,0.3);
  margin-top: 10rpx;

  .grid-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 30rpx 10rpx;
    border-right: 1rpx solid rgba(255, 255, 255, 0.05);
    transition: all 0.2s ease;
    
    &:nth-child(3n) {
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
