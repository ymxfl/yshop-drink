<template>
	<!-- #ifdef MP-WEIXIN -->
	<uv-navbar
	  :fixed="false"
	  :title="title"
	  left-arrow
	  @leftClick="$onClickLeft"
	  bg-color="#1a1a1a"
	  title-style="color: #F5D061; font-weight: bold;"
	  left-icon-color="#D4AF37"
	/>
	<!-- #endif -->
	<view class="page-wrap">
		<view v-if="content" class="content-card">
			<rich-text :nodes="content"></rich-text>
		</view>
		<view v-else class="loading-wrap">
			<uv-loading-icon mode="circle" color="#D4AF37"></uv-loading-icon>
		</view>
	</view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { mineServiceContent } from '@/api/user'

const title = ref('内容')
const content = ref('')

onLoad((option) => {
	if (option.name) {
		title.value = decodeURIComponent(option.name)
	}
	if (option.id) {
		getContent(option.id)
	}
})

const getContent = async (id) => {
	let data = await mineServiceContent({ id })
	if (data) {
		content.value = data.content
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
	padding: 24rpx;
}

.content-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	padding: 32rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.1);
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.3);
	color: #CCCCCC;
	font-size: 28rpx;
	line-height: 1.9;
}

.loading-wrap {
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 120rpx 0;
}
</style>
