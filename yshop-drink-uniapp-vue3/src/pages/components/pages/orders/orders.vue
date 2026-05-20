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
	<view class="order-page">
		<view class="tabs-wrap">
			<uv-tabs
				:list="tabList"
				:current="current"
				@change="change"
				keyName="name"
				:scrollable="false"
				:activeStyle="{ color: '#D4AF37', fontWeight: 'bold', fontSize: '30rpx' }"
				:inactiveStyle="{ color: '#9E9E9E', fontSize: '26rpx' }"
				:itemStyle="{ paddingLeft: '0', paddingRight: '0', height: '100rpx' }"
				:lineStyle="{ backgroundColor: '#D4AF37', height: '4rpx', borderRadius: '4rpx' }"
				:customStyle="{ backgroundColor: '#1E1E1E', borderBottom: '1rpx solid rgba(255,255,255,0.05)' }"
			></uv-tabs>
		</view>
		
		<scroll-view scroll-y class="orders-list" v-if="orders.length > 0" @scrolltolower="loadMore">
			<view class="order-card" v-for="(item, index) in orders" :key="index" @tap="detail(item.orderId)">
				<view class="order-header">
					<view class="shop-name">{{ item.shop.name }}</view>
					<view class="order-status" :class="getStatusClass(item.status)">{{ item.statusDto.title }}</view>
				</view>
				<view class="order-goods">
					<view class="good-row" v-for="(good, idx) in item.cartInfo" :key="idx">
						<image :src="good.image" mode="aspectFill" class="good-img"></image>
						<view class="good-info">
							<view class="good-name">{{ good.title }}</view>
							<view class="good-spec">{{ good.spec }}</view>
							<view class="good-price-row">
								<text class="good-price">¥{{ good.price }}</text>
								<text class="good-qty">×{{ good.number }}</text>
							</view>
						</view>
					</view>
				</view>
				<view class="order-footer">
					<view class="order-meta">
						<view class="order-time">{{ formatDateTime(item.createTime) }}</view>
						<view class="order-number">取餐号：{{ item.numberId }}</view>
					</view>
					<view class="order-total">
						<text class="total-label">共{{ goodsNum(item.cartInfo) }}件 · 实付</text>
						<text class="total-amount">¥{{ item.payPrice }}</text>
					</view>
				</view>
				<view class="order-actions">
					<view
						v-if="item.paid > 0 && item.status < 2 && item.refundStatus == 0"
						class="action-btn receive-btn"
						@tap.stop="receive(item)"
					>确认收到餐</view>
					<view class="action-btn detail-btn" @tap.stop="detail(item.orderId)">订单详情</view>
				</view>
			</view>
		</scroll-view>
		
		<uv-empty v-if="orders.length == 0" mode="order"></uv-empty>
	</view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad, onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { formatDateTime } from '@/utils/util'
import { orderGetOrders, orderReceive } from '@/api/order'

const main = useMainStore()
const { isLogin } = storeToRefs(main)
const title = ref('我的订单')

const page = ref(1)
const pageSize = ref(10)
const orders = ref([])
const tabList = ref([
	{ type: -1, name: '全部' },
	{ type: 0, name: '待支付' },
	{ type: 1, name: '进行中' },
	{ type: 4, name: '已完成' },
	{ type: -3, name: '退款单' }
])
const current = ref(0)
const type = ref(-1)

const goodsNum = computed(() => (goods) => {
	let num = 0
	goods.forEach(g => num += parseInt(g.number))
	return num
})

const getStatusClass = (status) => {
	if (status === 1) return 'status-processing'
	if (status >= 2) return 'status-done'
	return 'status-pending'
}

onLoad(() => {
	if (!isLogin.value) {
		uni.navigateTo({ url: '/pages/components/pages/login/login' })
	}
	getOrders(false)
})
onPullDownRefresh(() => { getOrders(false) })
onReachBottom(() => { getOrders(false) })

const change = (e) => {
	current.value = e.index
	type.value = e.type
	getOrders(true)
}
const loadMore = () => { getOrders(false) }

const getOrders = async (isRefresh = false) => {
	uni.showLoading({ title: '加载中' })
	if (isRefresh) {
		orders.value = []
		page.value = 1
	}
	const data = await orderGetOrders({ page: page.value, limit: pageSize.value, type: type.value })
	if (data) {
		orders.value = orders.value.concat(data)
		page.value += 1
	}
	uni.stopPullDownRefresh()
	uni.hideLoading()
}
const detail = (id) => {
	uni.navigateTo({ url: '/pages/components/pages/orders/detail?id=' + id })
}
const receive = async (order) => {
	const data = await orderReceive({ uni: order.orderId })
	if (data) await getOrders(true)
}
</script>

<style lang="scss">
page { background-color: #121212 !important; }
</style>

<style lang="scss" scoped>
.order-page {
	background-color: #121212;
	min-height: 100vh;
}
.tabs-wrap {
	background-color: #1E1E1E;
	position: sticky;
	top: 0;
	z-index: 100;
}
.orders-list {
	padding: 20rpx 25rpx;
	height: calc(100vh - 100rpx);
}
.order-card {
	background-color: #1E1E1E;
	border-radius: 20rpx;
	margin-bottom: 25rpx;
	overflow: hidden;
	border: 1rpx solid rgba(255,255,255,0.05);
	box-shadow: 0 8rpx 24rpx rgba(0,0,0,0.25);
}
.order-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 25rpx 30rpx 20rpx;
	border-bottom: 1rpx solid rgba(255,255,255,0.05);
	.shop-name { font-size: 30rpx; font-weight: bold; color: #FFFFFF; }
	.order-status {
		font-size: 24rpx;
		font-weight: bold;
		padding: 6rpx 20rpx;
		border-radius: 20rpx;
		&.status-processing { color: #D4AF37; background-color: rgba(212,175,55,0.1); border: 1rpx solid rgba(212,175,55,0.3); }
		&.status-done { color: #4CAF50; background-color: rgba(76,175,80,0.1); border: 1rpx solid rgba(76,175,80,0.3); }
		&.status-pending { color: #9E9E9E; background-color: rgba(158,158,158,0.1); border: 1rpx solid rgba(158,158,158,0.2); }
	}
}
.order-goods {
	padding: 20rpx 30rpx;
	border-bottom: 1rpx solid rgba(255,255,255,0.05);
	.good-row { display: flex; align-items: center; margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
	.good-img { width: 120rpx; height: 120rpx; border-radius: 12rpx; margin-right: 20rpx; flex-shrink: 0; }
	.good-info { flex: 1; overflow: hidden;
		.good-name { font-size: 28rpx; font-weight: bold; color: #FFFFFF; margin-bottom: 6rpx; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
		.good-spec { font-size: 22rpx; color: #9E9E9E; margin-bottom: 10rpx; }
		.good-price-row { display: flex; justify-content: space-between;
			.good-price { font-size: 28rpx; font-weight: bold; color: #D4AF37; }
			.good-qty { font-size: 24rpx; color: #9E9E9E; }
		}
	}
}
.order-footer {
	padding: 18rpx 30rpx;
	.order-meta { display: flex; justify-content: space-between; margin-bottom: 10rpx;
		.order-time, .order-number { font-size: 22rpx; color: #666; }
	}
	.order-total { display: flex; align-items: center; justify-content: flex-end;
		.total-label { font-size: 24rpx; color: #9E9E9E; margin-right: 8rpx; }
		.total-amount { font-size: 36rpx; font-weight: bold; color: #D4AF37; }
	}
}
.order-actions {
	display: flex;
	justify-content: flex-end;
	align-items: center;
	padding: 16rpx 30rpx 24rpx;
	gap: 20rpx;
	border-top: 1rpx solid rgba(255,255,255,0.05);
	.action-btn {
		font-size: 24rpx;
		padding: 14rpx 32rpx;
		border-radius: 30rpx;
		transition: all 0.2s ease;
		&:active { transform: scale(0.97); opacity: 0.85; }
	}
	.receive-btn { background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%); color: #121212; font-weight: bold; }
	.detail-btn { background-color: transparent; color: #D4AF37; border: 1rpx solid rgba(212,175,55,0.4); }
}
</style>
