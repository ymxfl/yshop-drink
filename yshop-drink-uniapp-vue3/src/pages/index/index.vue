<template>
  <scroll-view
    scroll-y
    class="page-wrap"
    :show-scrollbar="false"
    :bounces="false"
    :style="{ height: pageHeight }"
  >
    <!-- Banner Section -->
    <view class="banner-section" :style="{ height: bannerHeight + 'px' }">
      <uv-swiper
        v-if="listAds.length"
        class="bg-swiper"
        :height="bannerHeight"
        imgMode="aspectFill"
        keyName="image"
        :list="listAds"
        indicatorMode="dot"
        indicatorStyle="bottom"
      ></uv-swiper>
      <view v-else class="bg-swiper-fallback"></view>
      

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
          <image class="stat-icon" :src="statCoinIcon" mode="aspectFit"></image>
          <view class="stat-text">
            <text class="label">会员积分</text>
            <text class="value">{{ isLogin ? (member.integral || 0) : 0 }}</text>
          </view>
        </view>
        <view class="divider"></view>
        <view class="stat-item">
          <!-- Wallet SVG -->
          <image class="stat-icon" :src="statWalletIcon" mode="aspectFit"></image>
          <view class="stat-text">
            <text class="label">账户余额</text>
            <text class="value">¥{{ isLogin ? parseFloat(member.nowMoney || 0).toFixed(2) : '0.00' }}</text>
          </view>
        </view>
        <view class="divider"></view>
        <view class="stat-item" @tap="coupons">
          <!-- Ticket SVG -->
          <image class="stat-icon" :src="statTicketIcon" mode="aspectFit"></image>
          <view class="stat-text">
            <text class="label">可用卡券</text>
            <text class="value">{{ isLogin ? (member.couponCount || 0) : 0 }}张</text>
          </view>
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
import { ref, computed } from 'vue'
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
const beerGlassInactiveIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMzAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTYgOFYyNEM2IDI1LjEgNi45IDI2IDggMjZIMTZDMTcuMSAyNiAxOCAyNS4xIDE4IDI0VjgiIHN0cm9rZT0iIzQ0NDQ0NCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48cGF0aCBkPSJNMTggMTFIMjAuNUMyMS4zIDExIDIyIDExLjcgMjIgMTIuNVYxOS41QzIyIDIwLjMgMjEuMyAyMSAyMC41IDIxSDE4IiBzdHJva2U9IiM0NDQ0NDQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PC9zdmc+"
const beerGlassActiveIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMzAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTYgOFYyNEM2IDI1LjEgNi45IDI2IDggMjZIMTZDMTcuMSAyNiAxOCAyNS4xIDE4IDI0VjgiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48cGF0aCBkPSJNMTggMTFIMjAuNUMyMS4zIDExIDIyIDExLjcgMjIgMTIuNVYxOS41QzIyIDIwLjMgMjEuMyAyMSAyMC41IDIxSDE4IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PHBhdGggZD0iTTUgOEM1IDYuOSA1LjkgNiA3IDZIMTdDMTguMSA2IDE5IDYuOSAxOSA4QzE5IDguNTUgMTguNTUgOSAxOCA5SDZDNS40NSA5IDUgOC41NSA1IDhaIiBmaWxsPSIjRkZGREU3Ii8+PHBhdGggZD0iTTcgMTBWMjRIMTdWMTBIN1oiIGZpbGw9IiNENEFGMzciLz48L3N2Zz4="
const gridCouponsIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTIgOVY2YTIgMiAwIDAgMSAyLTJoMTZhMiAyIDAgMCAxIDIgMnYzYTIgMiAwIDAgMCAwIDR2M2EyIDIgMCAwIDEtMiAySDRhMiAyIDAgMCAxLTItMnYtM2EyIDIgMCAwIDAgMC00WiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPjxwYXRoIGQ9Ik0xMiA0djE2IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtZGFzaGFycmF5PSIzIDMiLz48L3N2Zz4="
const gridScoreIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMTIiIGN5PSI4IiByPSI1IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PHBhdGggZD0iTTQgMjBjMC0zLjMgMy42LTYgOC02czggMi43IDggNiIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPjxwYXRoIGQ9Ik0xMCA4aDRNMTIgNnY0IiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+PC9zdmc+"
const gridInviteIcon = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTIwIDEydjEwSDRWMTIiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48cmVjdCB4PSIyIiB5PSI3IiB3aWR0aD0iMjAiIGhlaWdodD0iNSIgcng9IjEiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48cGF0aCBkPSJNMTIgMjJWNyIgc3Ryb2tlPSIjRDRBRjM3IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPjxwYXRoIGQ9Ik0xMiA3Yy0xLjUtMy00LjUtMy00LjUgMFMxMC41IDcgMTIgN1oiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48cGF0aCBkPSJNMTIgN2MxLjUtMyA0LjUtMyA0LjUgMFMxMy41IDcgMTIgN1oiIHN0cm9rZT0iI0Q0QUYzNyIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4="

// 小程序 tab 页可用高度用 windowHeight（已扣导航与 tabBar），避免 100vh 与 scroll-view 计算不准导致无法滚动
const pageHeight = ref('100%')
// 轮播高度随屏幕宽度按 750:560 比例自适应（与 uv-swiper 的 rpx 高度一致）
const bannerHeight = computed(() => {
  try {
    const sys = uni.getSystemInfoSync()
    if (sys?.windowWidth) {
      return Math.round(sys.windowWidth * 560 / 750)
    }
  } catch (e) {
    /* ignore */
  }
  return 280
})

function updatePageHeight() {
  try {
    const sys = uni.getSystemInfoSync()
    if (sys && sys.windowHeight) {
      pageHeight.value = `${sys.windowHeight}px`
    }
  } catch (e) {
    /* ignore */
  }
}

const main = useMainStore()
const { member, store, isLogin } = storeToRefs(main)
const listAds = ref([])

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

onLoad(() => {
  updatePageHeight()
  handGetListAds()
})
onShow(() => {
  updatePageHeight()
  getUserInfo()
})
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
  overflow: hidden;

  .bg-swiper {
    width: 100%;
    height: 100%;

    :deep(.uv-swiper),
    :deep(.uv-swiper__wrapper),
    :deep(.uv-swiper__wrapper__item),
    :deep(.uv-swiper__wrapper__item__wrapper) {
      width: 100%;
      height: 100%;
    }

    :deep(.uv-swiper__wrapper__item__wrapper__image) {
      width: 100% !important;
      height: 100% !important;
      display: block;
    }
  }

  .bg-swiper-fallback {
    width: 100%;
    height: 100%;
    background: linear-gradient(145deg, #1a1510 0%, #2a2218 35%, #141820 70%, #121212 100%);
  }

  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(0,0,0,0) 40%, rgba(18,18,18,1) 100%);
    pointer-events: none;
    z-index: 1;
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
  padding: 24rpx 20rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.4);

  .stat-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 6rpx;

    .stat-icon {
      width: 36rpx;
      height: 36rpx;
    }

    .stat-text {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 2rpx;
    }

    .label {
      font-size: 20rpx;
      color: #9E9E9E;
      white-space: nowrap;
    }

    .value {
      font-size: 26rpx;
      color: #F5D061;
      font-weight: bold;
      white-space: nowrap;
    }
  }

  .divider {
    width: 1rpx;
    height: 50rpx;
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
