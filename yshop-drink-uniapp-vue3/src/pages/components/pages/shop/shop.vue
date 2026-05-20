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
	<view class="shop-page">
		<view class="search-bar">
			<uv-search
				margin="0"
				v-model="keywork"
				@custom="search(keywork)"
				bgColor="#2A2A2A"
				inputBackground="#2A2A2A"
				:showAction="true"
				actionText="搜索"
				actionStyle="color: #D4AF37; font-weight: bold;"
				placeholderColor="#666"
				color="#FFFFFF"
			></uv-search>
		</view>
		<view class="shop-list">
			<view
				v-for="(item, index) in list"
				:key="index"
				class="shop-card"
				:class="{ active: item.id == store.id }"
				@click="choice(item)"
			>
				<view class="shop-header">
					<image :src="item.image" class="shop-img" mode="aspectFill"></image>
					<view class="shop-info">
						<view class="shop-name">{{ item.name }}</view>
						<view class="shop-status" :class="{ open: item.status == 1 }">
							{{ item.status_text }}
						</view>
					</view>
					<view class="selected-badge" v-if="item.id == store.id">
						<text>当前</text>
					</view>
				</view>
				<view class="shop-body">
					<view class="info-row">
						<text class="label">📍</text>
						<text class="dist-highlight">距离您 {{ kmUnit(item.dis) }}</text>
					</view>
					<view class="info-row" v-if="item.distance > 0">
						<text class="label">🛵</text>
						<text>配送距离 {{ item.distance }}km · 配送费 ¥{{ item.delivery_price }}</text>
					</view>
					<view class="info-row" v-else>
						<text class="label">🛵</text>
						<text class="no-delivery">本店不支持外卖</text>
					</view>
					<view class="info-row">
						<text class="label">🏠</text>
						<text>{{ item.addressMap }} {{ item.address }}</text>
					</view>
					<view class="info-row">
						<text class="label">⏰</text>
						<text>营业时间 {{ formatDateTime(item.startTime, 'hh:mm') }} - {{ formatDateTime(item.endTime, 'hh:mm') }}</text>
					</view>
				</view>
				<view class="shop-actions">
					<view class="action-btn nav-btn" @click.stop="openLocation(item)">
						<text>📐 导航</text>
					</view>
					<view class="action-btn call-btn" @click.stop="call(item.mobile)">
						<text>📞 致电</text>
					</view>
					<view class="action-btn choose-btn" @click="choice(item)">
						<text>选择此店</text>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import {
  ref
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad } from '@dcloudio/uni-app'
import { formatDateTime, kmUnit } from '@/utils/util'
import {
  shopGetList
} from '@/api/market'
const main = useMainStore()
const { store, location } = storeToRefs(main)
const title = ref('选择门店')
const list = ref([])
const keywork = ref('')
const page = ref(1)
const pagesize = ref(10)

onLoad(() => {
	getShop();
})

const getShop = async(keywork = '') => {
	let data = await shopGetList({
		lat: location.value.latitude ? location.value.latitude : 0,
		lng: location.value.longitude ? location.value.longitude : 0,
		kw: keywork,
		shop_id: 0
	});
	if (data) {
		if (page.value == 1) {
			list.value = data;
		} else {
			for(let i in data) {
				list.value.push(data[i]);
			}
		}
	}
}
const openLocation = (shop) => {
	uni.openLocation({
		latitude: parseFloat(shop.lat),
		longitude: parseFloat(shop.lng),
		name: shop.name,
		address: shop.addressMap + shop.address,
		fail: (res) => {
			console.log(res);
		}
	})
}
const call = (mobile) => {
	uni.makePhoneCall({
		phoneNumber: mobile
	})
}
const search = (kw) => {
	page.value = 1;
	getShop(kw);
}
const choice = (shop) => {
	main.SET_STORE(shop);
	uni.$emit('refreshMenu')
	uni.switchTab({ 
		url: '/pages/menu/menu',
		success(res) {},
		fail(res) {
			console.log(res);
		}
	});
}

</script>

<style lang="scss">
page {
	background-color: #121212 !important;
}

.shop-page {
	background-color: #121212;
	min-height: 100vh;
	padding-bottom: 40rpx;
}

.search-bar {
	padding: 20rpx 30rpx;
	background-color: #1E1E1E;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
}

.shop-list {
	padding: 20rpx 25rpx;
}

.shop-card {
	background-color: #1E1E1E;
	border-radius: 20rpx;
	margin-bottom: 25rpx;
	overflow: hidden;
	border: 1rpx solid rgba(255, 255, 255, 0.05);
	box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.3);
	transition: all 0.2s ease;
	
	&.active {
		border-color: rgba(212, 175, 55, 0.5);
		box-shadow: 0 8rpx 32rpx rgba(212, 175, 55, 0.1);
	}
	
	&:active {
		transform: scale(0.99);
	}
}

.shop-header {
	display: flex;
	align-items: center;
	padding: 25rpx 25rpx 15rpx;
	position: relative;
	
	.shop-img {
		width: 90rpx;
		height: 90rpx;
		border-radius: 12rpx;
		margin-right: 20rpx;
		flex-shrink: 0;
	}
	
	.shop-info {
		flex: 1;
		overflow: hidden;
		
		.shop-name {
			font-size: 32rpx;
			font-weight: bold;
			color: #FFFFFF;
			margin-bottom: 8rpx;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}
		
		.shop-status {
			font-size: 22rpx;
			color: #9E9E9E;
			background-color: rgba(255, 255, 255, 0.05);
			display: inline-block;
			padding: 4rpx 16rpx;
			border-radius: 20rpx;
			
			&.open {
				color: #4CAF50;
				background-color: rgba(76, 175, 80, 0.1);
			}
		}
	}
	
	.selected-badge {
		background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
		color: #121212;
		font-size: 20rpx;
		font-weight: bold;
		padding: 6rpx 16rpx;
		border-radius: 20rpx;
		flex-shrink: 0;
		margin-left: 10rpx;
	}
}

.shop-body {
	padding: 0 25rpx 20rpx;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
	
	.info-row {
		display: flex;
		align-items: flex-start;
		margin-bottom: 12rpx;
		font-size: 24rpx;
		color: #9E9E9E;
		
		.label {
			margin-right: 10rpx;
			flex-shrink: 0;
		}
		
		.dist-highlight {
			color: #D4AF37;
			font-weight: bold;
		}
		
		.no-delivery {
			color: #E57373;
		}
	}
}

.shop-actions {
	display: flex;
	align-items: center;
	padding: 20rpx 25rpx;
	gap: 15rpx;
	
	.action-btn {
		font-size: 24rpx;
		padding: 12rpx 24rpx;
		border-radius: 30rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
		
		&:active {
			opacity: 0.8;
			transform: scale(0.97);
		}
	}
	
	.nav-btn {
		background-color: rgba(255, 255, 255, 0.05);
		color: #FFFFFF;
		border: 1rpx solid rgba(255, 255, 255, 0.1);
	}
	
	.call-btn {
		background-color: rgba(255, 255, 255, 0.05);
		color: #FFFFFF;
		border: 1rpx solid rgba(255, 255, 255, 0.1);
	}
	
	.choose-btn {
		flex: 1;
		background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
		color: #121212;
		font-weight: bold;
		border: none;
		font-size: 26rpx;
	}
}
</style>
