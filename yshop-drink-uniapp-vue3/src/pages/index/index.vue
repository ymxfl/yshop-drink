<template>
  <layout>
    <uv-sticky
      bg-color="#121212"
      offset-top="0"
      customNavHeight="0"
    >
      <uv-navbar
        :fixed="false"
        :safeAreaInsetTop="true"
        height="0"
        bgColor="transparent"
        leftIcon=""
      />
      <!-- #ifndef MP -->
      <blank size="10"></blank>
      <!-- #endif -->

      <blank size="5"></blank>
    </uv-sticky>

    <blank size="10"></blank>
	<view class="container">
			<view class="banner">
				<uv-swiper v-if="listAds.length" class="bg" height="300" imgMode="aspectFill" keyName="image" :list="listAds" indicatorMode="dot" indicatorStyle="bottom"></uv-swiper>
				<view class="intro">
					<view class="greet">您好，{{ isLogin ? member.nickname : '游客' }}</view>
					<view class="note">极客精酿 · 每日新鲜送达</view>
				</view>
			</view>
			<view class="content">
				<view class="flex justify-between yshop-menu">
					<view class="flex flex-column align-center yshop-menu-item "  @tap="takein">
						<view><image src="/static/images/index002.png" mode="aspectFit" class="img-01"></image></view>
						<view class="menu-title">自取</view>
						<view class="font-small text-light-gray">下单免排队</view>
					</view>
					<view class="flex flex-column align-center yshop-menu-item "  @tap="takeout">
						<view><image src="/static/images/index003.png" mode="aspectFit" class="img-01"></image></view>
						<view class="menu-title">外卖</view>
						<view class="font-small text-light-gray">精酿送到家</view>
					</view>
				</view>

				<!-- Stamp Card (集点卡) -->
				<view class="info stamp-card">
					<view class="stamp-header justify-between flex align-center w-100">
						<view class="stamp-title">
							<text class="title">精酿集点卡</text>
							<text class="sub-title">每消费1杯积1点，集满8点兑换1杯</text>
						</view>
						<view class="stamp-count">
							已集 <text class="highlight">{{ member.point || 0 }}</text> / 8
						</view>
					</view>
					<view class="stamp-grid w-100">
						<view v-for="i in 8" :key="i" class="stamp-item" :class="{ active: (member.point || 0) >= i }">
							<view class="stamp-glass">
								<view class="beer-liquid" :style="{ height: (member.point || 0) >= i ? '100%' : '0%' }"></view>
								<view class="beer-foam"></view>
							</view>
							<view class="stamp-number">{{ i }}</view>
						</view>
					</view>
				</view>

				 <view class="info">
					<view class="integral_section" @tap="coupons">
						<view class="top">
							<text class="title">我的卡券</text>
							<text class="value">{{member.couponCount}}</text>
						</view>
						<view class="bottom">
							可抵扣商品价格哦
						</view>
					</view>
					<view class="qrcode_section" @tap="coupons">
						<view class="action-btn">去领个券</view>
					</view>
				</view> 
				<view class="info">
					<view class="integral_section" @tap="goScore">
						<view class="top">
							<text class="title">积分商城</text>
						</view>
						<view class="bottom">
							进入积分商城兑换精酿周边及超值好礼
						</view>
					</view>
					<view class="qrcode_section" @tap="goScore">
						<image src="/static/images/balance.png" mode="aspectFit"></image>
						<view class="action-btn outline">逛一逛</view>
					</view>
				</view>
				
			</view>
	</view>
  </layout>
</template>

<script setup>
import {
  ref
} from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import {
  menuAds
} from '@/api/market'
import { userGetUserInfo } from '@/api/user'
import { storeToRefs } from 'pinia'
import { useMainStore } from '@/store/store'
//
const main = useMainStore()
const { member,store, isLogin} = storeToRefs(main)
//const store = ref(main.store)
const listAds = ref([])
// const isLogin = ref(main.isLogin)

const handGetListAds = async () => {
	let shop_id = store.id ? store.id : 0;
	let data = await menuAds({
		shop_id: shop_id
	});
	if (data) {
		listAds.value = data.list;
		console.log('listAds:',listAds.value)
		uni.setStorage({
				key: 'isActive',
				data: data.isActive
			});
		if(data.list.length > 0){
			uni.setStorage({
					key: 'shopAd',
					data: data.list[0].image
			 });
			}
		}
}

const takein = () => {
	main.SET_ORDER_TYPE('takein')
	uni.switchTab({
		url: '/pages/menu/menu'
	})
}

const takeout = () => {
	main.SET_ORDER_TYPE('takeout')
	uni.switchTab({
		url: '/pages/menu/menu'
	}) 
}

const coupons = () => { 
	console.log("--> % orderType:\n", main.orderType)
	console.log("--> % isLogin:\n", main.isLogin)
	if(!main.isLogin) {
		uni.navigateTo({url: '/pages/components/pages/login/login'})
		return
	}
	uni.navigateTo({
		url: '/pages/components/pages/coupons/coupons'
	})
}

const goScore = () => { 
	uni.navigateTo({
		url: '/pages/components/pages/scoreproduct/list'
	})
}




onLoad(() => {
 // main.init()
  handGetListAds()
})

const getUserInfo = async () => {
	if (isLogin.value) {
		const data = await userGetUserInfo()
		if (data) {
			main.SET_MEMBER(data)
		}
	}
}

onShow(() => {
	getUserInfo()
})

</script>

<style lang="scss">
.yshop-menu {
	//margin-bottom: 10rpx;
	// position: relative;
	margin-top: 20rpx;
}
.yshop-menu-item {
	background-color: rgba(30, 30, 30, 0.8);
	border: 1rpx solid rgba(212, 175, 55, 0.15);
	border-radius: 16rpx;
	width: 345rpx;
	padding-bottom: 30rpx;
	transition: all 0.2s ease;
	&:active {
		transform: scale(0.98);
		background-color: rgba(40, 40, 40, 0.9);
	}
}
	
.img-01 {
	width: 100rpx;
	height: 100rpx;
	margin-top: 30rpx;
}
.img-02 {
	width: 110rpx;
	height: 110rpx;
	margin-top: 20rpx;
}
	
	
/* #ifdef H5 */
page {
	height: auto;
	min-height: 100%;
}
/* #endif */
page {
	background-color: #121212 !important;
}
.banner {
	position: relative;
	width: 100%;
	border-radius: 0 0 40rpx 40rpx;
	overflow: hidden;
	
	&::after {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: linear-gradient(180deg, rgba(0, 0, 0, 0.1) 0%, rgba(18, 18, 18, 0.8) 100%);
		pointer-events: none;
	}
	
	.bg {
		width: 100%;
		height: 300rpx;
	}
	
	.intro {
		position: absolute;
		top: calc(40rpx + var(--status-bar-height));
		left: 40rpx;
		color: #FFFFFF;
		display: flex;
		flex-direction: column;
		z-index: 2;
		
		.greet {
			font-size: $font-size-lg;
			margin-bottom: 10rpx;
			font-weight: bold;
			color: #D4AF37;
		}
		
		.note {
			font-size: $font-size-sm;
			letter-spacing: 2rpx;
			opacity: 0.9;
		}
	}
}

.content {
	padding: 0 25rpx;
}

.menu-title {
	font-size: 32rpx;
	font-weight: bold;
	color: #D4AF37;
	margin-top: 15rpx;
}

.text-light-gray {
	color: #9E9E9E;
}

.info {
	position: relative;
	margin: 20rpx 0;
	border-radius: 16rpx;
	background-color: rgba(30, 30, 30, 0.8);
	border: 1rpx solid rgba(255, 255, 255, 0.05);
	box-shadow: 0 8rpx 32rpx 0 rgba(0, 0, 0, 0.3);
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 30rpx;
	
	.integral_section {
		flex: 1;
		display: flex;
		flex-direction: column;
		justify-content: center;
		
		.top {
			display: flex;
			align-items: center;
			
			.title {
				color: #FFFFFF;
				font-size: 30rpx;
				font-weight: bold;
				margin-right: 15rpx;
			}
			.value {
				font-size: 40rpx;
				font-weight: bold;
				color: #D4AF37;
			}
		}
		
		.bottom {
			font-size: 24rpx;
			color: #9E9E9E;
			display: flex;
			align-items: center;
			margin-top: 8rpx;
		}
	}
	
	.qrcode_section {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		
		image {
			width: 50rpx;
			height: 50rpx;
			margin-bottom: 10rpx;
		}
	}
}

.action-btn {
	background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
	color: #121212;
	font-weight: bold;
	font-size: 24rpx;
	padding: 12rpx 30rpx;
	border-radius: 30rpx;
	box-shadow: 0 4rpx 15rpx rgba(212, 175, 55, 0.3);
	
	&.outline {
		background: transparent;
		color: #D4AF37;
		border: 2rpx solid #D4AF37;
		box-shadow: none;
	}
}

/* Stamp Card CSS */
.stamp-card {
	flex-direction: column;
	align-items: stretch;
	border: 1rpx solid rgba(212, 175, 55, 0.25);
}
.stamp-header {
	.title {
		color: #D4AF37;
		font-size: 30rpx;
		font-weight: bold;
		display: block;
	}
	.sub-title {
		color: #9E9E9E;
		font-size: 22rpx;
		display: block;
		margin-top: 4rpx;
	}
	.stamp-count {
		color: #FFFFFF;
		font-size: 24rpx;
		.highlight {
			color: #D4AF37;
			font-size: 32rpx;
			font-weight: bold;
			margin: 0 4rpx;
		}
	}
}
.stamp-grid {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-top: 25rpx;
	padding: 10rpx 0;
}
.stamp-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	position: relative;
	width: 75rpx;
	
	.stamp-glass {
		width: 50rpx;
		height: 60rpx;
		border: 3rpx solid rgba(255, 255, 255, 0.3);
		border-radius: 4rpx 4rpx 10rpx 10rpx;
		position: relative;
		overflow: hidden;
		transition: all 0.3s ease;
		background: rgba(255, 255, 255, 0.05);
		
		&::after {
			content: '';
			position: absolute;
			right: -10rpx;
			top: 15rpx;
			width: 12rpx;
			height: 25rpx;
			border: 3rpx solid rgba(255, 255, 255, 0.3);
			border-left: none;
			border-radius: 0 6rpx 6rpx 0;
		}
	}
	
	.beer-liquid {
		position: absolute;
		bottom: 0;
		left: 0;
		right: 0;
		background: linear-gradient(0deg, #B27A17 0%, #D4AF37 100%);
		transition: height 0.5s ease-out;
		z-index: 1;
	}
	
	.beer-foam {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 10rpx;
		background: #FFFFFF;
		opacity: 0;
		z-index: 2;
		transition: opacity 0.3s ease;
		border-radius: 4rpx 4rpx 0 0;
	}
	
	.stamp-number {
		font-size: 20rpx;
		color: #9E9E9E;
		margin-top: 10rpx;
	}
	
	&.active {
		.stamp-glass {
			border-color: #D4AF37;
			box-shadow: 0 0 10rpx rgba(212, 175, 55, 0.4);
			&::after {
				border-color: #D4AF37;
			}
		}
		.beer-foam {
			opacity: 0.9;
		}
		.stamp-number {
			color: #D4AF37;
			font-weight: bold;
		}
	}
}

</style>
