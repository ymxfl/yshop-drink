<template>
	<uv-navbar
	  :fixed="false"
	  :title="title"
	  left-arrow
	  @leftClick="$onClickLeft"
	  bg-color="#121212"
	  :title-style="{ color: '#FFFFFF', fontWeight: 'bold' }"
	  left-icon-color="#D4AF37"
	/>
	<view class="page-wrap">
		<!-- 商品轮播图 -->
		<view class="carousel">
			<swiper indicator-dots :circular="true" duration="400">
				<swiper-item class="swiper-item" v-for="(item, index) in product.images" :key="index">
					<view class="image-wrapper">
						<image :src="item" class="product-img" @click="previewImage(index)" mode="aspectFill"></image>
					</view>
				</swiper-item>
			</swiper>
		</view>

		<!-- 商品信息 -->
		<view class="introduce-section" v-if="product.id">
			<text class="prod-title">{{ product.title }}</text>
			<view class="price-box">
				<view class="score-row">
					<text class="score-value">{{ product.score }}</text>
					<text class="score-label"> 积分兑换</text>
				</view>
				<view class="meta-row">
					<text class="meta-item">销量 {{ product.sales }}</text>
					<text class="meta-divider">·</text>
					<text class="meta-item">库存 {{ product.stock }}</text>
				</view>
			</view>
		</view>

		<!-- 商品详情富文本 -->
		<view class="detail-desc" v-if="product.desc">
			<view class="section-header">商品详情</view>
			<rich-text :nodes="product.desc"></rich-text>
		</view>

		<!-- 底部操作 -->
		<view class="fixed-bottom">
			<button class="exchange-btn" @click="confirm">立即兑换</button>
		</view>

		<uv-toast ref="uToast" />
	</view>
</template>

<script setup>
import {
  ref,
  getCurrentInstance
} from 'vue'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import {
  scoreShopExchange,
  scoreShopDetail
} from '../../api/score'
import cookie from '@/utils/cookie'
const { proxy } = getCurrentInstance();

const title = ref('商品详情')

const product = ref({})
const id = ref(false)

onPullDownRefresh(() => {
	getDetail(id.value);
})

onLoad((options) => {
   id.value = options.id;
   getDetail(options.id);
})

const confirm = () => {
	cookie.set('score_product', product.value)
	uni.navigateTo({
		url: '/pages/components/pages/scoreproduct/confirm'
	})
}

const previewImage = (index) => {
	uni.previewImage({
		current: product.value.images_text[index],
		urls: product.value.images_text,
		indicator: "number",
		loop: true
	})
}

const getDetail = async(id) => {
	let data = await scoreShopDetail({ id: id });
	uni.stopPullDownRefresh();
	product.value = data;
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
	padding-bottom: 160rpx;
}

/* 轮播图 */
.carousel {
	height: 680rpx;
	position: relative;
	background-color: #1E1E1E;

	swiper {
		height: 100%;
	}

	.swiper-item {
		height: 100%;
	}

	.image-wrapper {
		width: 100%;
		height: 100%;
	}

	.product-img {
		width: 100%;
		height: 100%;
	}
}

/* 商品信息 */
.introduce-section {
	background-color: #1E1E1E;
	padding: 30rpx;
	margin-top: 16rpx;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);

	.prod-title {
		font-size: 32rpx;
		font-weight: bold;
		color: #FFFFFF;
		line-height: 1.5;
		display: block;
		margin-bottom: 20rpx;
	}

	.price-box {
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.score-row {
		display: flex;
		align-items: baseline;
	}

	.score-value {
		font-size: 40rpx;
		font-weight: bold;
		color: #F5D061;
	}

	.score-label {
		font-size: 24rpx;
		color: #9E9E9E;
		margin-left: 6rpx;
	}

	.meta-row {
		display: flex;
		align-items: center;
		gap: 10rpx;
	}

	.meta-item {
		font-size: 22rpx;
		color: #9E9E9E;
	}

	.meta-divider {
		color: rgba(255, 255, 255, 0.2);
	}
}

/* 商品详情 */
.detail-desc {
	background-color: #1E1E1E;
	margin-top: 16rpx;
	padding: 30rpx;

	.section-header {
		font-size: 28rpx;
		font-weight: bold;
		color: #FFFFFF;
		padding-bottom: 20rpx;
		margin-bottom: 20rpx;
		border-bottom: 1rpx solid rgba(212, 175, 55, 0.2);
	}
}

/* 底部按钮 */
.fixed-bottom {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	padding: 20rpx 40rpx;
	padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
	background: linear-gradient(180deg, transparent 0%, #121212 30%);
}

.exchange-btn {
	height: 90rpx;
	line-height: 90rpx;
	border-radius: 50rpx;
	background: linear-gradient(135deg, #E6C655, #D4AF37);
	font-size: 32rpx;
	font-weight: bold;
	color: #1a1a1a;
	border: none;
	width: 100%;
}
</style>
