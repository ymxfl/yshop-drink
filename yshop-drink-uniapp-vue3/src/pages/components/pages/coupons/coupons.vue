<template>
	<uv-navbar
	  :fixed="false"
	  :title="title"
	  left-arrow
	  @leftClick="$onClickLeft"
	  bgColor="#121212"
	  :titleStyle="{ color: '#FFFFFF', fontWeight: 'bold' }"
	  leftIconColor="#D4AF37"
	/>
	<view class="container position-relative w-100 h-100 overflow-hidden">
		<view class="exchange-box">
			<view class="input-box">
				<input type="text" v-model="exchange_code" placeholder="请输入兑换码" placeholder-class="text-color-assist font-size-base" />
				<button type="primary" @click="exchange">兑换</button>
			</view>
		</view>
		<view class="tabbar">
			<scroll-view scroll-x class="tabbar-scroll" :show-scrollbar="false">
				<view class="tabbar-inner">
					<view class="tab" :class="{active: activeTabIndex == index}" 
						v-for="(item, index) in tabs" :key="index" @tap="handleTab(index)">
						<view class="title">{{ item.title }}</view>
					</view>
				</view>
			</scroll-view>
		</view>
		<view class="flex-fill">
			<scroll-view scroll-y class="coupon-list" @scrolltolower="getCoupons(activeTabIndex)">
				<view class="wrapper"  v-if="0 === activeTabIndex">
					<uv-empty v-if="myCoupons.length == 0" mode="list"></uv-empty>
					<view class="coupon" v-for="(item, index) in myCoupons" :key="index" @tap="openDetailModal(item,index)">
						<view class="taobao">
							<view class="ticket">
								<view class="left">
									<image
										class="picture"
										:src="item.image"
										mode="aspectFill"
									></image>
									<view class="introduce">
										<view class="top">
											￥
											<text class="big">{{item.value}}</text>
											<view>
												满{{item.least}}减{{item.value}}
											</view>
										</view>
										<view class="type">{{ item.title }}</view>
										<view class="date u-line-1">{{formatDateTime(item.startTime, 'yyyy-MM-dd')}}-{{formatDateTime(item.endTime, 'yyyy-MM-dd')}}</view>
									</view>
								</view>
								<view class="right" @click.stop="" v-if="activeTabIndex == 1">
									<view class="use immediate-use" :round="true" @tap="receive(item, index)" >立即领取</view>
								</view>
								<view class="right" @click.stop="" v-if="activeTabIndex == 0">
									<view v-if="item.status == 0" class="use immediate-use" :round="true" @tap="useCouponWith(item)" >立即使用</view>
									<view v-else class="used">已使用</view>
								</view>
							</view>
						</view>
					</view>
				</view>
				<view class="wrapper" v-if="1 === activeTabIndex">
					<uv-empty v-if="notCoupons.length == 0" mode="list"></uv-empty>
					<view class="coupon" v-for="(item, index) in notCoupons" :key="index" @tap="openDetailModal(item,index)">
						<view class="taobao">
							<view class="ticket">
								<view class="left">
									<image
										class="picture"
										:src="item.image"
										mode="aspectFill"
									></image>
									<view class="introduce">
										<view class="top">
											￥
											<text class="big">{{item.value}}</text>
											<view>
												满{{item.least}}减{{item.value}}
											</view>
										</view>
										<view class="type">{{ item.title }}</view>
										<view class="date u-line-1">{{formatDateTime(item.startTime, 'yyyy-MM-dd')}}-{{formatDateTime(item.endTime, 'yyyy-MM-dd')}}</view>
									</view>
								</view>
								<view class="right" @click.stop="" v-if="activeTabIndex == 1">
									<!-- <view class="use immediate-use" :round="true" @tap="receive(item, index)" >立即领取</view> -->
									<view  class="use immediate-use" :round="true" v-if="item.isReceive == 0" @tap="receive(item, index)" >立即领取</view>
									<view v-else class="used immediate-use">已领取</view>
								</view>
								<view class="right" @click.stop="" v-if="activeTabIndex == 0">
									<view v-if="item.status == 0" class="use immediate-use" :round="true" @tap="useCouponWith(item)" >立即使用</view>
									<view v-else class="used">已使用</view>
								</view>
							</view>
						</view>
					</view>
				</view>
				<view class="wrapper" v-if="2 === activeTabIndex">
					<uv-empty v-if="usedCoupons.length == 0" mode="list"></uv-empty>
					<view class="coupon" v-for="(item, index) in usedCoupons" :key="index" @tap="openDetailModal(item,index)">
						<view class="taobao">
							<view class="ticket">
								<view class="left">
									<image class="picture" :src="item.image" mode="aspectFill"></image>
									<view class="introduce">
										<view class="top">
											￥
											<text class="big">{{item.value}}</text>
											<view>满{{item.least}}减{{item.value}}</view>
										</view>
										<view class="type">{{ item.title }}</view>
										<view class="date u-line-1">{{formatDateTime(item.startTime, 'yyyy-MM-dd')}}-{{formatDateTime(item.endTime, 'yyyy-MM-dd')}}</view>
									</view>
								</view>
								<view class="right">
									<view class="used">已使用</view>
								</view>
							</view>
						</view>
					</view>
				</view>
				<view class="wrapper" v-if="3 === activeTabIndex">
					<uv-empty v-if="expiredCoupons.length == 0" mode="list"></uv-empty>
					<view class="coupon" v-for="(item, index) in expiredCoupons" :key="index" @tap="openDetailModal(item,index)">
						<view class="taobao">
							<view class="ticket">
								<view class="left">
									<image class="picture" :src="item.image" mode="aspectFill"></image>
									<view class="introduce">
										<view class="top">
											￥
											<text class="big">{{item.value}}</text>
											<view>满{{item.least}}减{{item.value}}</view>
										</view>
										<view class="type">{{ item.title }}</view>
										<view class="date u-line-1">{{formatDateTime(item.startTime, 'yyyy-MM-dd')}}-{{formatDateTime(item.endTime, 'yyyy-MM-dd')}}</view>
									</view>
								</view>
								<view class="right">
									<view class="used">已过期</view>
								</view>
							</view>
						</view>
					</view>
				</view>
			</scroll-view>
		</view>
		<modal custom :show="detailModalVisible" @cancel="closeDetailModal" width="90%">
			<view class="modal-content">
				<view class="d-flex font-size-extra-lg text-color-base just-content-center mb-20">{{ coupon.title }}</view>
				<view class="d-flex font-size-sm text-color-base mb-20">
					有效期：{{formatDateTime(coupon.startTime, 'yyyy-MM-dd')}}-{{formatDateTime(coupon.endTime, 'yyyy-MM-dd')}}
				</view>
				<view class="d-flex font-size-sm text-color-base mb-20">
					领取时间：{{formatDateTime(coupon.createTime)}}
				</view>
				<view class="d-flex font-size-sm text-color-base mb-20">
					券价值：满{{ coupon.least }}减{{ coupon.value }}
				</view>
				<view class="d-flex font-size-sm text-color-base mb-20" v-if="activeTabIndex == 1">
					每人限领：{{ coupon.limit }} 张
				</view>
				<view class="d-flex font-size-sm text-color-base mb-20">
					适用范围：{{typeInfo(coupon.type)}}
				</view>
				<view class="d-flex font-size-sm text-color-base mb-20">
					适用店铺：{{coupon.shopName}}
				</view>
				<view class="d-flex align-items-center just-content-center" v-if="activeTabIndex == 0">
					<button type="primary" @tap="useCoupon" class="use-coupon-btn">立即使用</button>
				</view>
				<view class="d-flex align-items-center just-content-center" v-if="activeTabIndex == 1">
					<button type="primary" @tap="receive(coupon, couponIndex)" class="use-coupon-btn">立即领取</button>
				</view>
			</view>
		</modal>
		
		<!--轻提示-->
		<uv-toast ref="uToast"></uv-toast>
	</view>
</template>

<script setup>
import {
  ref,
  watch
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad,onShow ,onPullDownRefresh,onHide} from '@dcloudio/uni-app'
import { formatDateTime,kmUnit } from '@/utils/util'
import {
  couponReceive,
  couponMine,
  couponIndexApi
} from '../../api/coupon'
import { userGetUserInfo } from '@/api/user'
const main = useMainStore()
const { isLogin } = storeToRefs(main)
const title = ref('优惠券')

const tabs = ref([
	{title: '我的优惠券', page:1, pagesize:10, source: 'mine', mineType: 0},
	{title: '未领优惠券', page:1, pagesize:10, source: 'not'},
	{title: '已使用', page:1, pagesize:10, source: 'mine', mineType: 1},
	{title: '已过期', page:1, pagesize:10, source: 'mine', mineType: 2},
])
const activeTabIndex = ref(0)
const detailModalVisible = ref(false)
const coupon = ref({})
const couponIndex = ref(0)
const exchange_code = ref('')
const uToast = ref()
const myCoupons = ref([])
const notCoupons = ref([])
const usedCoupons = ref([])
const expiredCoupons = ref([])

const clearTabList = (tabIndex) => {
	if (tabIndex === 0) myCoupons.value = []
	if (tabIndex === 1) notCoupons.value = []
	if (tabIndex === 2) usedCoupons.value = []
	if (tabIndex === 3) expiredCoupons.value = []
}

const refreshMember = async () => {
	if (!isLogin.value) return
	const data = await userGetUserInfo()
	if (data) {
		main.SET_MEMBER(data)
	}
}

onShow(() => {
	getCoupons(activeTabIndex.value)
})
onPullDownRefresh(() => {
	clearTabList(activeTabIndex.value)
	tabs.value[activeTabIndex.value].page = 1
	getCoupons(activeTabIndex.value)
})
watch(activeTabIndex, () => {
   getCoupons(activeTabIndex.value)
})

// 兑换
const exchange = async() => {
	let data = await couponReceive({code:exchange_code.value});
	if (data) {
		uToast.value.show({
			message: '兑换成功',
			type: 'success'
		});
		tabs.value[0].page = 1
		tabs.value[1].page = 1
		getCoupons(0)
		getCoupons(1)
		refreshMember()
	}
}
// 使用范围
const typeInfo = (type) => {
	if (type == 0) {
		return '通用'
	}
	if (type == 1) {
		return '自取'
	}
	if (type == 2) {
		return '外卖'
	}
}
const handleTab = (index) => {
	console.log('activeTabIndex2:',index)
	activeTabIndex.value = index
}
const getCoupons = async(tabIndex) => {
	const tab = tabs.value[tabIndex]
	const page = tab.page
	const pagesize = tab.pagesize
	if (tab.source === 'mine') {
		const data = await couponMine({type: tab.mineType, page, pagesize}) || []
		if (tabIndex === 0) myCoupons.value = data
		if (tabIndex === 2) usedCoupons.value = data
		if (tabIndex === 3) expiredCoupons.value = data
	}
	if (tab.source === 'not') {
		notCoupons.value = await couponIndexApi({page, pagesize}) || []
	}
	uni.stopPullDownRefresh()
}
const openDetailModal = (coupon,index) => {
	couponIndex.value = index;
	coupon.value = coupon
	detailModalVisible.value = true
}
const useCouponWith = (coupon) => {
	//coupon.value = coupon
	useCoupon();
}
const closeDetailModal = () => {
	detailModalVisible.value = false
	coupon.value = {}
}
const useCoupon = () => {
	uni.switchTab({
		url: '/pages/menu/menu'
	})
}
const showTip1 = () => {
	uni.showToast({
		title: '您暂时还没有赠送中卡券哦~',
		icon: 'none'
	})
}
const showTip2 = () => {
	uni.showToast({
		title: '您暂时还没有券码哦~',
		icon: 'none'
	})
}
// 领取优惠券
const receive = async(coupon,index) => {
	let data = await couponReceive({id:coupon.id});
	if (data) {
		uToast.value.show({
			message: '领取成功',
			type: 'success'
		});
		detailModalVisible.value = false
		tabs.value[1].page = 1
		getCoupons(1)
		tabs.value[0].page = 1
		getCoupons(0)
		refreshMember()
	}
}


</script>

<style lang="scss" scoped>
page {
	background-color: #121212 !important;
}

.container {
	display: flex;
	flex-direction: column;
	background-color: #121212;
	min-height: 100vh;
}

.exchange-box {
	flex-shrink: 0;
	height: 160rpx;
	background-color: #1E1E1E;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);

	.input-box {
		display: flex;
		align-items: center;
		width: 85%;
		height: 88rpx;
		background-color: #121212;
		border: 1rpx solid rgba(212, 175, 55, 0.2);
		border-radius: 44rpx;
		padding: 0 8rpx 0 30rpx;
		box-sizing: border-box;

		input {
			flex: 1;
			height: 100%;
			font-size: 28rpx;
			color: #FFFFFF;
			background: transparent;
			border: none;
			outline: none;
		}

		button {
			height: 72rpx;
			line-height: 72rpx;
			background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%) !important;
			color: #121212 !important;
			font-weight: bold;
			font-size: 26rpx;
			border: none;
			border-radius: 36rpx;
			padding: 0 40rpx;
			display: flex;
			align-items: center;
			justify-content: center;
			margin: 0;

			&:active {
				opacity: 0.9;
			}
		}
	}
}

.tabbar {
	flex-shrink: 0;
	width: 100%;
	height: 100rpx;
	background-color: #1E1E1E;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);

	.tabbar-scroll {
		width: 100%;
		height: 100%;
		white-space: nowrap;
	}

	.tabbar-inner {
		display: inline-flex;
		min-width: 100%;
		height: 100%;
	}

	.tab {
		flex: 1;
		min-width: 25%;
		height: 100%;
		display: inline-flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		font-size: 28rpx;
		color: #9E9E9E;
		position: relative;
		
		.title {
			padding: 10rpx 0;
			white-space: nowrap;
		}
		
		&.active {
			color: #D4AF37;
			font-weight: bold;
			
			.title {
				border-bottom: 4rpx solid #D4AF37;
			}
		}
	}
}

.coupon-list {
	height: calc(100vh - 100rpx - 160rpx);
	background-color: #121212;
	/* #ifdef H5 */
	height: calc(100vh - 100rpx - 160rpx - 44px);
	/* #endif */
}

.wrapper {
	padding: 30rpx 24rpx;
	display: flex;
	flex-direction: column;
	
	.coupon {
		display: flex;
		flex-direction: column;
		background-color: #1E1E1E;
		margin-bottom: 24rpx;
		border-radius: 12rpx;
		border: 1rpx solid rgba(212, 175, 55, 0.1);
		box-shadow: 0 8rpx 20rpx rgba(0, 0, 0, 0.4);
		position: relative;
		overflow: visible;
		
		&::before {
			content: "";
			position: absolute;
			background-color: #121212;
			width: 24rpx;
			height: 24rpx;
			bottom: 50rpx;
			left: -12rpx;
			border-radius: 100%;
			z-index: 2;
			border-right: 1rpx solid rgba(212, 175, 55, 0.1);
		}
		
		&::after {
			content: "";
			position: absolute;
			background-color: #121212;
			width: 24rpx;
			height: 24rpx;
			bottom: 50rpx;
			right: -12rpx;
			border-radius: 100%;
			z-index: 2;
			border-left: 1rpx solid rgba(212, 175, 55, 0.1);
		}
	}
}

.use-coupon-btn {
	width: 95%;
	border-radius: 50rem !important;
	background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%) !important;
	color: #121212 !important;
	font-weight: bold;
	border: none;
}

.modal-content {
	background-color: #1E1E1E;
	padding: 40rpx 30rpx;
	border-radius: 16rpx;
	color: #FFFFFF;
	
	.text-color-base {
		color: #FFFFFF !important;
	}
	
	.use-coupon-btn {
		margin-top: 30rpx;
	}
}

.taobao {
	background-color: transparent;
	width: 100%;

	.ticket {
		display: flex;
		width: 100%;
		
		.left {
			width: 72%;
			padding: 24rpx;
			background-color: transparent;
			border-right: dashed 2rpx rgba(255, 255, 255, 0.1);
			display: flex;
			align-items: center;

			.picture {
				border-radius: 8rpx;
				width: 140rpx;
				height: 140rpx;
				flex-shrink: 0;
			}

			.introduce {
				margin-left: 20rpx;
				flex: 1;
				min-width: 0;

				.top {
					color: #F5D061;
					font-size: 26rpx;
					display: flex;
					align-items: baseline;

					.big {
						font-size: 54rpx;
						font-weight: 800;
						margin-right: 8rpx;
						color: #F5D061;
					}
					
					view {
						font-size: 20rpx;
						color: #9E9E9E;
					}
				}
				.type {
					font-size: 26rpx;
					color: #FFFFFF;
					font-weight: bold;
					margin-top: 4rpx;
				}
				.date {
					margin-top: 8rpx;
					font-size: 20rpx;
					color: #9E9E9E;
				}
			}
		}
		.right {
			width: 28%;
			padding: 24rpx 10rpx;
			background-color: transparent;
			display: flex;
			align-items: center;
			justify-content: center;

			.use {
				height: 56rpx;
				line-height: 56rpx;
				padding: 0 20rpx;
				font-size: 22rpx;
				border-radius: 28rpx;
				color: #121212 !important;
				background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%) !important;
				font-weight: bold;
				margin: 0;
				white-space: nowrap;

				&:active {
					opacity: 0.9;
				}
			}
			.used {
				height: 56rpx;
				line-height: 56rpx;
				padding: 0 20rpx;
				font-size: 22rpx;
				border-radius: 28rpx;
				color: #888888 !important;
				background-color: #2A2A2A !important;
				margin: 0;
				white-space: nowrap;
				border: 1rpx solid rgba(255, 255, 255, 0.05);
			}
		}
	}
}
</style>
