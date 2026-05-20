<template>
	<!-- #ifdef MP-WEIXIN -->
	<uv-navbar
	  :fixed="false"
	  :title="title"
	  left-arrow
	  @leftClick="$onClickLeft"
	  :bg-color="navBgColor"
	  :title-style="navTitleStyle"
	  :left-icon-color="navIconColor"
	/>
	<!-- #endif -->
	<view class="page-wrap">
		<!-- 收货地址卡片 -->
		<view class="section-card address-card" @tap="chooseAddress">
			<view class="address-icon">
				<text class="iconfont-pin">📍</text>
			</view>
			<view class="address-content" v-if="address.realName">
				<view class="address-name-row">
					<text class="addr-name">{{ address.realName }}</text>
					<text class="addr-phone">{{ address.phone }}</text>
				</view>
				<text class="addr-detail">{{ address.address }} {{ address.detail }}</text>
			</view>
			<view class="address-placeholder" v-else>
				<text>请选择收货地址</text>
			</view>
			<view class="address-arrow">›</view>
		</view>

		<!-- 商品信息卡片 -->
		<view class="section-card product-section">
			<view class="section-title">积分商城</view>
			<view class="product-row">
				<image :src="product.image" mode="aspectFill" class="product-image"></image>
				<view class="product-info">
					<text class="product-title">{{ product.title }}</text>
					<view class="product-score-row">
						<text class="product-score">{{ product.score }}</text>
						<text class="score-unit"> 积分</text>
					</view>
				</view>
				<text class="product-qty">×1</text>
			</view>
		</view>

		<!-- 价格汇总卡片 -->
		<view class="section-card total-section">
			<view class="total-row">
				<text class="total-label">积分抵扣</text>
				<text class="total-value">{{ product.score }} 积分</text>
			</view>
			<view class="total-divider"></view>
			<view class="total-row">
				<text class="total-label grand-total">合计</text>
				<text class="total-value gold">{{ product.score }} 积分</text>
			</view>
		</view>
	</view>

	<!-- 底部操作栏 -->
	<view class="bottom-bar">
		<view class="summary-text">
			<text class="sum-label">合计：</text>
			<text class="sum-value">{{ product.score }}</text>
			<text class="sum-unit"> 积分</text>
		</view>
		<view class="submit-btn" @tap="submit">立即兑换</view>
	</view>

	<uv-toast ref="uToast" />
</template>

<script setup>
import {
  ref,
  computed,
  getCurrentInstance
} from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import {
  scoreShopExchange,
  scoreShopDetail
} from '../../api/score'
import cookie from '@/utils/cookie'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
const { proxy } = getCurrentInstance();
const main = useMainStore()
const { address, isLogin } = storeToRefs(main)

const title = ref("确认订单")
const navBgColor = '#1a1a1a'
const navTitleStyle = 'color: #F5D061; font-weight: bold;'
const navIconColor = '#D4AF37'

const product = ref({})

onLoad(() => {
	if (!isLogin.value) {
		uni.navigateTo({ url: '/pages/components/pages/login/login' })
	}
	product.value = cookie.get('score_product')
})

// 选择地址
const chooseAddress = () => {
	uni.navigateTo({
		url: '/pages/components/pages/address/address?is_choose=true&scene=scoreShop'
	})
}

// 提交
const submit = async() => {
	if (!address.value.id) {
		proxy.$refs.uToast.show({
			message: '请选择收货地址',
			type: 'warning',
		})
		return
	}
	let data = await scoreShopExchange({
		productId: product.value.id,
		addressId: address.value.id,
		num: 1
	})

	if (data) {
		cookie.remove('score_product')
		setTimeout(function() {
			uni.navigateTo({
				url: '/pages/components/pages/scoreproduct/order'
			})
		}, 1000)
	}
}
</script>

<style lang="scss">
page {
	background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
.page-wrap {
	background-color: #121212;
	min-height: 100vh;
	padding: 20rpx 24rpx 200rpx;
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

/* 通用卡片 */
.section-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	padding: 28rpx 24rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.1);
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.3);
}

/* 地址卡片 */
.address-card {
	display: flex;
	align-items: center;
	gap: 16rpx;

	.address-icon {
		font-size: 36rpx;
		flex-shrink: 0;
	}

	.address-content {
		flex: 1;
		min-width: 0;
	}

	.address-name-row {
		display: flex;
		align-items: center;
		gap: 20rpx;
		margin-bottom: 8rpx;
	}

	.addr-name {
		font-size: 28rpx;
		font-weight: bold;
		color: #FFFFFF;
	}

	.addr-phone {
		font-size: 24rpx;
		color: #9E9E9E;
	}

	.addr-detail {
		font-size: 24rpx;
		color: #9E9E9E;
		display: block;
	}

	.address-placeholder {
		flex: 1;
		font-size: 28rpx;
		color: #9E9E9E;
	}

	.address-arrow {
		font-size: 36rpx;
		color: #D4AF37;
		flex-shrink: 0;
	}
}

/* 商品区 */
.product-section {
	.section-title {
		font-size: 24rpx;
		color: #9E9E9E;
		margin-bottom: 20rpx;
		padding-bottom: 16rpx;
		border-bottom: 1rpx solid rgba(255, 255, 255, 0.06);
	}

	.product-row {
		display: flex;
		align-items: center;
		gap: 20rpx;
	}

	.product-image {
		width: 150rpx;
		height: 150rpx;
		border-radius: 10rpx;
		flex-shrink: 0;
		background-color: #2A2A2A;
	}

	.product-info {
		flex: 1;
		min-width: 0;
	}

	.product-title {
		font-size: 28rpx;
		color: #FFFFFF;
		display: block;
		margin-bottom: 14rpx;
		line-height: 1.4;
	}

	.product-score-row {
		display: flex;
		align-items: baseline;
	}

	.product-score {
		font-size: 32rpx;
		font-weight: bold;
		color: #F5D061;
	}

	.score-unit {
		font-size: 22rpx;
		color: #9E9E9E;
	}

	.product-qty {
		font-size: 28rpx;
		color: #9E9E9E;
		flex-shrink: 0;
	}
}

/* 价格汇总 */
.total-section {
	.total-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 10rpx 0;
	}

	.total-divider {
		height: 1rpx;
		background-color: rgba(255, 255, 255, 0.06);
		margin: 10rpx 0;
	}

	.total-label {
		font-size: 26rpx;
		color: #9E9E9E;
	}

	.grand-total {
		color: #FFFFFF;
		font-weight: bold;
	}

	.total-value {
		font-size: 26rpx;
		color: #CCCCCC;
	}

	.gold {
		color: #F5D061;
		font-weight: bold;
		font-size: 30rpx;
	}
}

/* 底部操作栏 */
.bottom-bar {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 20rpx 30rpx;
	padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
	background-color: #1E1E1E;
	border-top: 1rpx solid rgba(212, 175, 55, 0.15);
	box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.5);

	.summary-text {
		display: flex;
		align-items: baseline;
	}

	.sum-label {
		font-size: 24rpx;
		color: #9E9E9E;
	}

	.sum-value {
		font-size: 36rpx;
		font-weight: bold;
		color: #F5D061;
	}

	.sum-unit {
		font-size: 22rpx;
		color: #9E9E9E;
	}

	.submit-btn {
		background: linear-gradient(135deg, #E6C655, #D4AF37);
		color: #1a1a1a;
		font-size: 28rpx;
		font-weight: bold;
		height: 80rpx;
		line-height: 80rpx;
		padding: 0 60rpx;
		border-radius: 40rpx;
	}
}
</style>