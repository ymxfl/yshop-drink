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
	<view class="container w-100 h-100 overflow-hidden">
		<view class="textarea">
			<textarea placeholder-class="text-color-assist font-size-base" v-model="remark"
				class="remark w-100 border-box font-size-base"
				:class="{'text-color-danger': remarkLength > 50, 'text-color-assist' : remarkLength <=50}"
				placeholder="请填写备注信息" focus/>
			<view class="tips" :class="{'text-color-danger': remarkLength > 50, 'text-color-assist' : remarkLength <=50}">
				{{ remarkLength }}/50
			</view>
		</view>
		<view class="d-flex font-size-base text-color-assist" style="margin: 40rpx 0;">
			快捷输入
		</view>
		<view class="quick-inputs d-flex flex-wrap justify-content-start">
			<view class="quick-input" v-for="(item, index) in quickInputs" :key="index" @tap="handleQuickInput(item)">
				{{ item }}
			</view>
		</view>
		<view class="d-flex just-content-center align-items-center" style="margin-top: 60rpx;">
			<button type="primary" class="submit-btn font-size-base" @tap="submit">完成</button>
		</view>
		<!--轻提示-->
		<uv-toast ref="uToast"></uv-toast>
	</view>
</template>

<script setup>
import {
  ref,
  computed
} from 'vue'
import { onLoad} from '@dcloudio/uni-app'

const remark = ref('')
const quickInputs = ref( ['请放门把手上', '请放门口', '请放前台桌上', '如地址封闭管理，请电话与我联系'])
const uToast = ref()
	
onLoad((opt) => {
	remark.value = opt.remark
})	

const remarkLength = computed(() => { 
	return remark.value.length
})
const isDanger = computed(() => { 
	return remark.value.length > 50
})

const handleQuickInput = (item) => {
	remark.value = remark.value.concat(" ", item)
}
const submit = () => {
	if (remark.value.length > 50) {
		uToast.value.show({
			message: '不能超过50个字符',
			type: 'error'
		});
		return
	}
	uni.navigateTo({
		url: "/pages/components/pages/pay/pay?remark=" + remark.value
	})
}
	

</script>

<style lang="scss">
page {
	background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
	.container {
		background-color: #121212;
		min-height: 100vh;
		padding: 30rpx;
	}
	.container {
		padding: 30rpx 40rpx;
		
		.textarea {
			position: relative;
			
			.remark {
				border-radius: 8rpx;
				padding: 30rpx 40rpx;
				height: 320rpx;
				color: #CCCCCC;
				background-color: #1E1E1E;
				border: 1rpx solid rgba(212, 175, 55, 0.1);
			}
			
			.tips {
				position: absolute;
				bottom: 30rpx;
				right: 40rpx;
			}
		}
		
		.quick-inputs {
			padding-right: 20rpx;
			
			.quick-input {
				background-color: #1E1E1E;
				border: 2rpx solid #D4AF37;
				color: #D4AF37;
				font-size: $font-size-base;
				padding: 16rpx 26rpx;
				margin-right: 20rpx;
				margin-bottom: 20rpx;
			}
		}
		
		.submit-btn {
			width: 90%;
			height: 80rpx;
			border-radius: 40rpx;
			line-height: 80rpx;
		}
	}
</style>
