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
		<!-- 商品区 -->
		<uv-waterfall v-model="list" :add-time="0" ref="uWaterfall" @changeList="changeList" :left-gap="20"
			:right-gap="20"
			:column-gap="20">
			<template v-slot:list1>
				<view class="product-card" v-for="(item, index) in list1" :key="index" @click="goDetail(item)">
					<view class="card-img-wrap">
						<image :src="item.image" mode="widthFix" class="card-img"></image>
					</view>
					<view class="card-body">
						<view class="card-title">{{ item.title }}</view>
						<view class="card-score">
							<text class="score-num">{{ item.score }}</text>
							<text class="score-unit"> 积分</text>
						</view>
					</view>
				</view>
			</template>
			<template v-slot:list2>
				<view class="product-card" v-for="(item, index) in list2" :key="index" @click="goDetail(item)">
					<view class="card-img-wrap">
						<image :src="item.image" mode="widthFix" class="card-img"></image>
					</view>
					<view class="card-body">
						<view class="card-title">{{ item.title }}</view>
						<view class="card-score">
							<text class="score-num">{{ item.score }}</text>
							<text class="score-unit"> 积分</text>
						</view>
					</view>
				</view>
			</template>
		</uv-waterfall>
		<uv-load-more v-if="list.length > 0" :status="status" color="#9E9E9E"></uv-load-more>
		<uv-empty v-if="list.length == 0" mode="list" :icon-color="'#9E9E9E'"></uv-empty>
	</view>
</template>

<script setup>
import {
  ref,
  computed,
  getCurrentInstance
} from 'vue'
import { onReachBottom,onShow,onPullDownRefresh} from '@dcloudio/uni-app'
import {
  scoreShopIndex
} from '../../api/score'
const { proxy } = getCurrentInstance();

const title = ref('积分商城')
const navBgColor = '#1a1a1a'
const navTitleStyle = 'color: #F5D061; font-weight: bold;'
const navIconColor = '#D4AF37'

const list = ref([])
const page = ref(1)
const pagesize = ref(10)
const status = ref('loadmore')
const list1 = ref([])
const list2 = ref([])

const uWaterfall = ref()

let currentInstance = getCurrentInstance()

onShow(() => {
	getProduct()
})

onReachBottom(async() => {
	if (status.value == 'loading') {
		return;
	}
	page.value++
	status.value = 'loading'; 
	let data = await scoreShopIndex({
		page: page.value,
		pagesize: pagesize.value
	});
	if (data) {
		list.value = list.value.concat(data);
		if (data.length == 0) {
			page.value--;
			status.value = 'nomore';
		} else if (data.length < pagesize.value) {
			status.value = 'nomore';
		} else {
			status.value = 'loadmore';
		}
	} else {
		status.value = 'loadmore';
	}
})

onPullDownRefresh(() => {
	page.value = 1;
	getProduct()
})

const changeList = (e) => {
	if(e.name == 'list1'){
		list1.value.push(e.value)
	}else{
		list2.value.push(e.value)
	}
}
const goDetail = (item) => {
	uni.navigateTo({
		url: '/pages/components/pages/scoreproduct/detail?id=' + item.id
	})
}
const  getProduct = async() => {
	status.value = 'loading';
	let data = await scoreShopIndex({
		page: page.value,
		pagesize: pagesize.value
	});
	uni.stopPullDownRefresh();
	if (data) {
		list.value = data;
		if (data.length < pagesize.value) {
			status.value = 'nomore';
		}
	} else {
		status.value = 'nomore';
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
	padding: 20rpx 10rpx 40rpx;
}

.product-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	overflow: hidden;
	margin-bottom: 20rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.12);
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.4);
	transition: all 0.2s ease;

	&:active {
		transform: scale(0.97);
		border-color: rgba(212, 175, 55, 0.35);
	}

	.card-img-wrap {
		width: 100%;
		overflow: hidden;
	}

	.card-img {
		width: 100%;
		display: block;
	}

	.card-body {
		padding: 16rpx 18rpx 20rpx;
	}

	.card-title {
		font-size: 26rpx;
		color: #FFFFFF;
		line-height: 1.4;
		margin-bottom: 10rpx;
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}

	.card-score {
		display: flex;
		align-items: baseline;
	}

	.score-num {
		font-size: 30rpx;
		font-weight: bold;
		color: #F5D061;
	}

	.score-unit {
		font-size: 22rpx;
		color: #9E9E9E;
	}
}
</style>
