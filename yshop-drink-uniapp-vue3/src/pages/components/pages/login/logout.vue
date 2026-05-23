<template>
	<!-- <layout> -->
		<uv-navbar
		  :fixed="false"
		  :title="title"
		  left-arrow
		  @leftClick="$onClickLeft"
		  bg-color="#121212"
		  :title-style="{ color: '#FFFFFF', fontWeight: 'bold' }"
		  left-icon-color="#D4AF37"
		/>
		<view class="top">
			<button type="primary" size="default" class="login-btn" @click="logout">
				确定退出登录
			</button>
			<uv-toast ref="uToast"></uv-toast>
		</view>
	<!-- </layout> -->
</template>

<script setup>
import {
  ref
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
const main = useMainStore()
const { member,isLogin } = storeToRefs(main)
const uToast = ref()
const title = ref('退出')

const logout = () => {
	uni.removeStorageSync( 'userinfo');
	uni.removeStorageSync( 'accessToken');
	main.SET_MEMBER({});
	main.SET_TOKEN('');
	uToast.value.show({
		message: '已退出',
		type: 'success'
	});
	setTimeout(function() {
		uni.redirectTo({
			url: '/pages/components/pages/login/login',
		})
	}, 1000);
}
	
</script>

<style lang="scss">
page {
	background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
	.top {
		background-color: #121212;
		min-height: 100vh;
		display: flex; 
		height: 100%;
	}
	button{
		 margin: auto;
	}
</style>
