<template>
	<uv-navbar
	  :fixed="false"
	  :title="title"
	  left-arrow
	  @leftClick="$onClickLeft"
	  :bg-color="navBgColor"
	  :title-style="navTitleStyle"
	  :left-icon-color="navIconColor"
	/>
	<view class="page-wrap">
		<view class="form-card">
			<view class="form-item" v-for="field in formFields" :key="field.key">
				<view class="form-label">{{ field.label }}</view>
				<view class="form-value-wrap" v-if="field.type === 'text'">
					<input
						class="form-input"
						:placeholder="field.placeholder"
						v-model="form[field.key]"
						placeholder-class="input-placeholder"
					/>
				</view>
				<view class="form-value-wrap clickable" v-else-if="field.type === 'picker'" @tap="chooseLocation">
					<text :class="['form-input', form[field.key] ? 'has-value' : 'placeholder']">
						{{ form[field.key] ? form[field.key] : field.placeholder }}
					</text>
					<text class="field-arrow">›</text>
				</view>
				<view class="form-value-wrap" v-else-if="field.type === 'radio'">
					<view class="radio-group">
						<view
							class="radio-btn"
							:class="{ 'active': !form.isDefault }"
							@tap="form.isDefault = 0"
						>否</view>
						<view
							class="radio-btn"
							:class="{ 'active': form.isDefault }"
							@tap="form.isDefault = 1"
						>是</view>
					</view>
				</view>
			</view>
		</view>

		<view class="save-section">
			<view class="save-btn" @tap="save">保存地址</view>
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
import {
  getAddressAddAndEdit
} from '../../api/address'

const main = useMainStore()
const { isLogin, addresses } = storeToRefs(main)

const title = ref('编辑地址')
const navBgColor = '#1a1a1a'
const navTitleStyle = 'color: #F5D061; font-weight: bold;'
const navIconColor = '#D4AF37'

const form = ref({
	realName: '',
	isDefault: 0,
	phone: '',
	address: '',
	detail: '',
	latitude: '',
	longitude: ''
})

const formFields = [
	{ key: 'realName', label: '收货人', placeholder: '请输入收货人姓名', type: 'text' },
	{ key: 'phone', label: '联系方式', placeholder: '请输入手机号码', type: 'text' },
	{ key: 'address', label: '收货地址', placeholder: '点击选择收货地址', type: 'picker' },
	{ key: 'detail', label: '详细地址', placeholder: '请输入门牌号、楼层等', type: 'text' },
	{ key: 'isDefault', label: '默认地址', placeholder: '', type: 'radio' },
]

onLoad((option) => {
	if (option.id) {
		form.value = addresses.value.find(item => item.id == option.id)
	}
})

const save = async() => {
	let data = await getAddressAddAndEdit(form.value);
	if (data) {
		setTimeout(function() {
			uni.navigateBack()
		}, 2000);
	}
}

const chooseLocation = async() => {
	uni.chooseLocation({
		success: function (res) {
			form.value.address = res.address + ' ' + res.name;
			form.value.latitude = res.latitude;
			form.value.longitude = res.longitude;
		}
	});
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
	padding: 24rpx 24rpx 60rpx;
}

/* 表单卡片 */
.form-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.1);
	overflow: hidden;
	margin-bottom: 40rpx;
}

.form-item {
	display: flex;
	align-items: center;
	padding: 30rpx 24rpx;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
	min-height: 90rpx;

	&:last-child {
		border-bottom: none;
	}
}

.form-label {
	width: 180rpx;
	font-size: 28rpx;
	color: #FFFFFF;
	font-weight: 500;
	flex-shrink: 0;
}

.form-value-wrap {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: space-between;

	&.clickable {
		cursor: pointer;
	}
}

.form-input {
	flex: 1;
	font-size: 26rpx;
	color: #CCCCCC;
	background: transparent;
	border: none;

	&.placeholder {
		color: #666666;
	}

	&.has-value {
		color: #CCCCCC;
	}
}

.input-placeholder {
	color: #666666;
}

.field-arrow {
	font-size: 36rpx;
	color: #D4AF37;
	margin-left: 10rpx;
}

/* 单选按钮组 */
.radio-group {
	display: flex;
	gap: 16rpx;
}

.radio-btn {
	padding: 10rpx 36rpx;
	border-radius: 8rpx;
	border: 2rpx solid rgba(255, 255, 255, 0.15);
	color: #9E9E9E;
	font-size: 26rpx;
	transition: all 0.2s;

	&.active {
		background: linear-gradient(135deg, #E6C655, #D4AF37);
		color: #1a1a1a;
		border-color: #D4AF37;
		font-weight: bold;
	}
}

/* 保存按钮 */
.save-section {
	padding: 0 20rpx;
}

.save-btn {
	height: 90rpx;
	line-height: 90rpx;
	border-radius: 50rpx;
	background: linear-gradient(135deg, #E6C655, #D4AF37);
	font-size: 32rpx;
	font-weight: bold;
	color: #1a1a1a;
	text-align: center;
	box-shadow: 0 4rpx 16rpx rgba(212, 175, 55, 0.3);

	&:active {
		opacity: 0.9;
		transform: scale(0.99);
	}
}
</style>
