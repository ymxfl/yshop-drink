<template>
	<layout>
		<uv-navbar
		  :fixed="false"
		  :title="title"
		  left-arrow
		  @leftClick="$onClickLeft"
		  bgColor="#121212"
		  :titleStyle="{ color: '#FFFFFF', fontWeight: 'bold' }"
		  leftIconColor="#D4AF37"
		/>
		<view class="mine-page">
			<!-- Hero Banner -->
			<view class="hero-banner">
				<view class="hero-bg"></view>
				<view class="hero-content">
					<view class="avatar-wrap" @tap="isLogin ? serv({type:'pages',pages:'/pages/components/pages/mine/userinfo'}) : login()">
						<image 
							:src="isLogin && member.avatar ? member.avatar : '/static/images/mine/default.png'"
							class="avatar-img"
						></image>
						<view class="avatar-ring"></view>
					</view>
					<view class="user-info">
						<view class="nickname" @tap="isLogin ? serv({type:'pages',pages:'/pages/components/pages/mine/userinfo'}) : login()">
							<text>{{ isLogin ? member.nickname : '点击登录' }}</text>
							<view class="iconfont iconarrow-right" style="color:#D4AF37;font-size:24rpx;margin-left:8rpx;"></view>
						</view>
						<view class="user-tag" v-if="isLogin">精酿会员</view>
					</view>
				</view>
				
				<!-- Stats Grid -->
				<view class="stats-grid">
					<view class="stat-item" @tap="serv({type:'pages',pages:'/pages/components/pages/coupons/coupons'})">
						<view class="stat-value">{{ isLogin ? member.couponCount : 0 }}</view>
						<view class="stat-label">优惠券</view>
					</view>
					<view class="stat-divider"></view>
					<view class="stat-item" @tap="serv({type:'pages', pages: '/pages/components/pages/balance/bill?cate=1'})">
						<view class="stat-value">{{ isLogin ? member.integral : 0 }}</view>
						<view class="stat-label">积分</view>
					</view>
					<view class="stat-divider"></view>
					<view class="stat-item">
						<view class="stat-value">{{ isLogin ? member.nowMoney : '0.00' }}</view>
						<view class="stat-label">余额</view>
					</view>
					<view class="stat-divider"></view>
					<view class="stat-item" @tap="serv({type:'pages', pages: '/pages/components/pages/balance/bill?cate=0'})">
						<view class="stat-value">{{ isLogin ? member.sumMoney : '0.00' }}</view>
						<view class="stat-label">历史消费</view>
					</view>
				</view>
			</view>
			
			<!-- Service Section -->
			<view class="service-section">
				<view class="section-title">我的服务</view>
				<view class="service-list">
					<uv-cell-group :customStyle="{ background: 'transparent' }">
						<block v-for="(item, index) in services" :key="index">
							<uv-cell
								:title="item.name"
								v-if="item.type == 'contact'"
								:isLink="true"
								:customStyle="{ background: '#1E1E1E', borderBottom: '1rpx solid rgba(255,255,255,0.05)' }"
								:titleStyle="{ color: '#FFFFFF' }"
								:arrowStyle="{ color: '#D4AF37' }"
							>
								<template #icon>
									<image :src="item.image" style="width: 40rpx;height: 40rpx;" class="mr-1"></image>
								</template>
							</uv-cell>
							<uv-cell
								:isLink="true"
								:title="item.name"
								v-else-if="item.type == 'call'"
								v-on:click="makePhoneCall(item.phone)"
								:customStyle="{ background: '#1E1E1E', borderBottom: '1rpx solid rgba(255,255,255,0.05)' }"
								:titleStyle="{ color: '#FFFFFF' }"
								:arrowStyle="{ color: '#D4AF37' }"
							>
								<template #icon>
									<image :src="item.image" style="width: 40rpx;height: 40rpx;" class="mr-1"></image>
								</template>
							</uv-cell>
							<uv-cell
								:isLink="true"
								:title="item.name"
								v-else
								@tap="serv(item)"
								:customStyle="{ background: '#1E1E1E', borderBottom: '1rpx solid rgba(255,255,255,0.05)' }"
								:titleStyle="{ color: '#FFFFFF' }"
								:arrowStyle="{ color: '#D4AF37' }"
							>
								<template #icon>
									<image :src="item.image" style="width: 40rpx;height: 40rpx;" class="mr-1"></image>
								</template>
							</uv-cell>
						</block>
					</uv-cell-group>
				</view>
			</view>
		</view>
	</layout>
</template>

<script setup>
import {
  ref,
  computed
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad, onShow } from '@dcloudio/uni-app'
import {
  userGetUserInfo,
  mineService
} from '@/api/user'
const main = useMainStore()
const { member, isLogin } = storeToRefs(main)

const title = ref('个人中心')
const services = ref([])

onLoad(() => {
	getServices();
})
onShow(() => {
	getUserInfo();
})

const getUserInfo = async() => {
	if (isLogin.value) {
		let data = await userGetUserInfo();
		if (data) {
			main.SET_MEMBER(data);
		}
	}
}
const getServices = async() => {
	let data = await mineService();
	if (data) {
		services.value = data;
	}
}
const makePhoneCall = (phoneNumber) => {
	uni.makePhoneCall({
		phoneNumber: phoneNumber,
	})
}
const login = () => {
	uni.navigateTo({
		url: '/pages/components/pages/login/login'
	})
}
const serv = (item) => {
	switch (item.type) {
		case 'pages':
			if (!isLogin.value) {
				login()
				return
			}
			uni.navigateTo({
				url: item.pages
			})
			break;
		case 'miniprogram':
			uni.navigateToMiniProgram({
				appId: item.app_id
			})
			break;
		case 'menu':
			uni.navigateTo({
				url: '/pages/components/pages/mine/service?id=' + item.id + '&name=' + item.name
			})
			break;
		case 'content':
			uni.navigateTo({
				url: '/pages/components/pages/mine/content?id=' + item.id + '&name=' + item.name
			})
			break;
	}
}
</script>

<style lang="scss" scoped>
page {
	background-color: #121212 !important;
}

.mine-page {
	background-color: #121212;
	min-height: 100vh;
}

.hero-banner {
	background: linear-gradient(180deg, #1A1500 0%, #121212 100%);
	position: relative;
	padding-bottom: 30rpx;
	
	.hero-bg {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 300rpx;
		background: radial-gradient(ellipse at 50% 0%, rgba(212, 175, 55, 0.12) 0%, transparent 70%);
	}
	
	.hero-content {
		display: flex;
		align-items: center;
		padding: 40rpx 40rpx 30rpx;
		position: relative;
		z-index: 1;
		
		.avatar-wrap {
			position: relative;
			margin-right: 30rpx;
			width: 140rpx;
			height: 140rpx;
			flex-shrink: 0;
			
			.avatar-img {
				width: 140rpx;
				height: 140rpx;
				border-radius: 100%;
				position: relative;
				z-index: 2;
			}
			
			.avatar-ring {
				position: absolute;
				top: -6rpx;
				left: -6rpx;
				right: -6rpx;
				bottom: -6rpx;
				border-radius: 100%;
				border: 3rpx solid #D4AF37;
				z-index: 1;
				box-shadow: 0 0 20rpx rgba(212, 175, 55, 0.4);
			}
		}
		
		.user-info {
			flex: 1;
			
			.nickname {
				display: flex;
				align-items: center;
				font-size: 36rpx;
				font-weight: bold;
				color: #FFFFFF;
				margin-bottom: 12rpx;
			}
			
			.user-tag {
				display: inline-block;
				background: linear-gradient(135deg, rgba(212, 175, 55, 0.2) 0%, rgba(212, 175, 55, 0.1) 100%);
				color: #D4AF37;
				border: 1rpx solid rgba(212, 175, 55, 0.4);
				font-size: 20rpx;
				padding: 6rpx 20rpx;
				border-radius: 20rpx;
			}
		}
	}
}

.stats-grid {
	display: flex;
	align-items: center;
	margin: 0 30rpx;
	background-color: rgba(30, 30, 30, 0.8);
	border: 1rpx solid rgba(212, 175, 55, 0.15);
	border-radius: 20rpx;
	padding: 30rpx 0;
	position: relative;
	z-index: 1;
	
	.stat-item {
		flex: 1;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
		
		&:active {
			opacity: 0.7;
		}
		
		.stat-value {
			font-size: 40rpx;
			font-weight: bold;
			color: #D4AF37;
			margin-bottom: 10rpx;
		}
		
		.stat-label {
			font-size: 22rpx;
			color: #9E9E9E;
		}
	}
	
	.stat-divider {
		width: 1rpx;
		height: 60rpx;
		background-color: rgba(255, 255, 255, 0.08);
	}
}

.service-section {
	padding: 30rpx 25rpx;
	
	.section-title {
		font-size: 30rpx;
		font-weight: bold;
		color: #FFFFFF;
		margin-bottom: 20rpx;
		padding-left: 12rpx;
		border-left: 4rpx solid #D4AF37;
	}
	
	.service-list {
		background-color: #1E1E1E;
		border-radius: 16rpx;
		overflow: hidden;
		border: 1rpx solid rgba(255, 255, 255, 0.05);
	}
}
</style>
