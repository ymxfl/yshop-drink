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
		<view class="form-card">
			<list-cell :hover="false" bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">头像</view>
					<view class="input flex-fill">
						<view class="form-input w-100 d-flex align-items-center avatar-row">
							<view class="flex user-box align-items-center">
								<view class="mr-1">
									<uv-avatar :src="member.avatar" size="60"></uv-avatar>
								</view>
								<view v-if="!member.avatar" class="flex-1">
									<button class="avatar-btn" size="mini" open-type="chooseAvatar" @chooseavatar="chooseavatar">更改头像</button>
								</view>
							</view>
						</view>
					</view>
				</view>
			</list-cell>
			<list-cell :hover="false" bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">昵称</view>
					<view class="input flex-fill">
						<input
							class="field-input"
							type="nickname"
							placeholder="请填写昵称"
							placeholder-class="input-placeholder"
							v-model="member.nickname"
						/>
					</view>
				</view>
			</list-cell>
			<list-cell :hover="false" bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">手机号码</view>
					<view class="input flex-fill">
						<input class="field-input field-disabled" type="text" v-model="member.mobile" disabled />
					</view>
				</view>
			</list-cell>
			<list-cell :hover="false" bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">性别</view>
					<view class="input flex-fill">
						<view class="radio-group">
							<view class="radio" :class="{'checked': member.gender == '0'}" @tap="member.gender=0">先生</view>
							<view class="radio" :class="{'checked': member.gender == '1'}" @tap="member.gender=1">女士</view>
						</view>
					</view>
				</view>
			</list-cell>
			<list-cell :hover="false" :arrow="!member.birthday" bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">生日</view>
					<view class="input flex-fill">
						<picker mode="date" :value="member.birthday" :start="startDate" :end="endDate" @change="handleDateChange">
							<text class="picker-text">{{ member.birthday ? member.birthday : '请选择' }}</text>
						</picker>
					</view>
				</view>
			</list-cell>
			<list-cell :hover="false" last bgcolor="#1E1E1E" color="#FFFFFF" padding="30rpx 24rpx">
				<view class="form-input w-100 d-flex align-items-center">
					<view class="label">加入时间</view>
					<view class="input flex-fill">
						<input class="field-input field-disabled" type="text" v-model="member.createTime" disabled />
					</view>
				</view>
			</list-cell>
		</view>

		<view class="save-section">
			<view class="save-btn" @tap="save">保存</view>
		</view>
	</view>
</template>

<script setup>
import {
  ref,
  computed
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad,onShow} from '@dcloudio/uni-app'
import { formatDateTime } from '@/utils/util'
import {
  userEdit
} from '@/api/user'
import { VUE_APP_UPLOAD_URL } from '@/config';
const main = useMainStore()
const { lang } = storeToRefs(main)

const title = ref('用户设置')
const date = ref('')
const member = ref({})

onLoad(() => {
	member.value = main.member;
	member.value.createTime = formatDateTime(member.value.createTime);
})	
onShow(() => {
	date.value = getDate({format: true})
})

const startDate = computed(() => { 
	return getDate('start');
})
const endDate = computed(() => { 
	return getDate('end');
})

const chooseavatar = (e) => {
	uni.uploadFile({
		url: VUE_APP_UPLOAD_URL, 
		filePath: e.detail.avatarUrl,
		name: 'file',
		header: {
			Authorization: 'Bearer ' + member.value.accessToken,
			lang: lang.value,
			'content-type': 'application/x-www-form-urlencoded;charset=UTF-8'
		},
		success(uploadFileResult){
			if (uploadFileResult) {
				const upload = JSON.parse(uploadFileResult.data);
				member.value.avatar = upload.data;
			}
		}, 
		fail(e){
			console.log('网络链接错误', e)
		}
	});
}
const getDate = (type) => {
	const date = new Date();
	let year = date.getFullYear();
	let month = date.getMonth() + 1;
	let day = date.getDate();

	if (type === 'start') {
		year = year - 60;
	} else if (type === 'end') {
		year = year + 2;
	}
	month = month > 9 ? month : '0' + month;;
	day = day > 9 ? day : '0' + day;
	return `${year}-${month}-${day}`;
}
const handleDateChange = (e) => {
	member.value.birthday = e.target.value
}
const save = async() => {
	let data = await userEdit({
		nickname: member.value.nickname,
		mobile: member.value.mobile,
		gender: member.value.gender,
		birthday: member.value.birthday,
		avatar: member.value.avatar
	});
	if (data) {
		const member2 = Object.assign(main.member, member.value)
		main.SET_MEMBER(member2)	
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
	padding: 24rpx 24rpx 60rpx;
}

.form-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.1);
	overflow: hidden;

	:deep(.tui-list-cell::after) {
		border-bottom-color: rgba(255, 255, 255, 0.06);
	}
}

.form-input {
	.label {
		width: 160rpx;
		font-size: $font-size-base;
		color: #FFFFFF;
		flex-shrink: 0;
	}

	.field-input {
		width: 100%;
		font-size: $font-size-base;
		color: #CCCCCC;
		background: transparent;
	}

	.field-disabled {
		color: #9E9E9E;
	}

	.picker-text {
		font-size: $font-size-base;
		color: #CCCCCC;
	}

	.radio-group {
		display: flex;
		justify-content: flex-start;
		gap: 16rpx;

		.radio {
			padding: 10rpx 30rpx;
			border-radius: 8rpx;
			border: 2rpx solid rgba(255, 255, 255, 0.15);
			color: #9E9E9E;
			font-size: $font-size-base;

			&.checked {
				background: linear-gradient(135deg, #E6C655, #D4AF37);
				color: #121212;
				border-color: #D4AF37;
				font-weight: bold;
			}
		}
	}
}

.avatar-row {
	position: relative;
}

.avatar-btn {
	background: linear-gradient(135deg, #E6C655, #D4AF37) !important;
	color: #121212 !important;
	border: none;
	font-size: 24rpx;
}

.input-placeholder {
	color: #666666;
}

.save-section {
	padding: 40rpx 20rpx 0;
}

.save-btn {
	height: 90rpx;
	line-height: 90rpx;
	border-radius: 50rpx;
	background: linear-gradient(135deg, #E6C655, #D4AF37);
	font-size: 32rpx;
	font-weight: bold;
	color: #121212;
	text-align: center;
	box-shadow: 0 4rpx 16rpx rgba(212, 175, 55, 0.3);

	&:active {
		opacity: 0.9;
		transform: scale(0.99);
	}
}
</style>
