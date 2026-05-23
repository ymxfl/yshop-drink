<template>
	<layout>
		<uv-navbar
		  :fixed="false"
		  :title="title"
		  left-arrow
		  @leftClick="$onClickLeft"
		  bg-color="#121212"
		  :title-style="{ color: '#FFFFFF', fontWeight: 'bold' }"
		  left-icon-color="#D4AF37"
		/>
		<view class="login-page">
			<view class="login-content">
				<view class="login-title">欢迎登录</view>
				<view class="login-subtitle">登录后即可点单、查看订单与优惠</view>

				<view class="form-card">
					<view class="form-item">
						<text class="form-label">手机号</text>
						<input
							class="form-input"
							type="number"
							v-model="mobile"
							placeholder="请输入手机号"
							placeholder-class="input-placeholder"
						/>
					</view>
					<view class="form-tip">未注册的手机号验证后自动创建账号</view>

					<view class="form-item captcha-row">
						<view class="captcha-input-wrap">
							<text class="form-label">验证码</text>
							<input
								class="form-input"
								type="number"
								v-model="captcha"
								placeholder="请输入验证码"
								placeholder-class="input-placeholder"
							/>
						</view>
						<button
							class="captcha-btn"
							:class="{ active: mobile && captchaText === '获取验证码' }"
							@tap="getCaptcha"
						>
							{{ captchaText }}
							<uv-code
								:seconds="seconds"
								@end="endCaptcha"
								@start="startCaptcha"
								ref="uCode"
								@change="changeCapcha"
							></uv-code>
						</button>
					</view>
				</view>

			</view>

			<view class="login-actions">
				<button class="login-btn-primary" @tap="submit">登录</button>
				<!-- #ifdef MP-WEIXIN -->
				<view class="divider">
					<view class="divider-line"></view>
					<text class="divider-text">其他方式</text>
					<view class="divider-line"></view>
				</view>
				<button
					type="primary"
					class="login-btn-wechat"
					open-type="getPhoneNumber"
					@getphonenumber="loginForWechatMini"
				>
					手机号快捷登录
				</button>
				<!-- #endif -->
			</view>

			<view class="login-footer">
				<view class="agreement" @tap="onChange">
					<view class="agreement-radio">
						<radio :checked="isChecked" color="#D4AF37" @tap.stop="onChange" />
					</view>
					<text class="agreement-text">
						我已经阅读并遵守
						<text class="link" @tap.stop="serv(29,'用户协议')">《用户协议》</text>
						与
						<text class="link" @tap.stop="serv(30,'隐私政策')">《隐私政策》</text>
					</text>
				</view>
			</view>

			<uv-toast ref="uToast"></uv-toast>
		</view>
	</layout>
</template>

<script setup>
import {
  ref
} from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useMainStore } from '@/store/store'
import {
  userAuthSession,
  userLoginForWechatMini,
  smsSend,
  userLogin
} from '@/api/auth'
import * as util  from '@/utils/util'
import { mobile as testMobible } from '@/uni_modules/uv-ui-tools/libs/function/test'
const main = useMainStore()
const title = ref('登录')
const mobile = ref('')
const captcha = ref('')
const captchaText = ref('获取验证码')
const seconds = ref(60)
const isChecked = ref(false)
const openid = ref(main.openid)
const uToast = ref()
const uCode = ref()

onShow(() => {
	uni.hideLoading()
	// #ifdef MP-WEIXIN
	if(!openid.value){
		wechatMiniLogin();
	}
	// #endif
})

const wechatMiniLogin = () => {
	uni.login({
		provider: 'weixin'
	}).then(async (res) => {
		let data = await userAuthSession({
			code: res.code
		});
		if (data) {
			main.SET_OPENID(data.openId)
			openid.value = data.openId
		}
	});
}

const loginForWechatMini = async (e) => {
	if(!isChecked.value){
		uToast.value.show({
			message: '请勾选下面协议',
			type: 'error'
		});
		return
	}
	if (e.detail.encryptedData && e.detail.iv) {
		let data = await userLoginForWechatMini({
			encryptedData: e.detail.encryptedData,
			iv: e.detail.iv,
			openid: openid.value
		});
		if (data) {
			main.SET_MEMBER(data.userInfo);
			main.SET_TOKEN(data.accessToken);
			uToast.value.show({
				title: '登录成功',
				type: 'success'
			});
			setTimeout(function() {
				uni.navigateBack();
			}, 2000);
		}
	}
}

const getCaptcha = async () => {
	if (testMobible(mobile.value) == false) {
		uToast.value.show({
			message: '手机号码格式不对',
			type: 'error'
		});
		return
	}

	let data = await smsSend({
		mobile: mobile.value,
		scene: 1
	});
	if (data) {
		uCode.value.start();
	}
}

const startCaptcha = () => {}
const endCaptcha = () => {
	captchaText.value = '获取验证码';
}
const changeCapcha = (text)  => {
	captchaText.value = text;
}

const submit = () => {
	if (testMobible(mobile.value) == false) {
		uToast.value.show({
			message: '手机号码格式不对',
			type: 'error'
		});
		return
	}

	if(!isChecked.value){
		uToast.value.show({
			message: '请勾选下面协议',
			type: 'error'
		});
		return
	}

	login()
}

const login = async () => {
	let from = 'routine'
	// #ifdef H5
	from = 'h5'
	if(util.isWeixin()){
		from = 'wechat'
	}
	// #endif
	let data = await userLogin({
		mobile: mobile.value,
		code: captcha.value,
		from: from,
		openid: openid.value
	})
	if (data) {
		uni.setStorage({
			key: 'userinfo',
			data: data.userInfo
		});
		uni.setStorage({
			key: 'accessToken',
			data: data.accessToken
		});
		main.SET_MEMBER(data.userInfo);
		main.SET_TOKEN(data.accessToken);
		uToast.value.show({
			message: '登录成功',
			type: 'success'
		});
		setTimeout(function() {
			uni.navigateBack();
		}, 2000);
	}
}

const serv = (id,name) => {
	uni.navigateTo({
		url: '/pages/components/pages/mine/content?id=' + id + '&name=' + name
	})
}

const onChange = () => {
	isChecked.value = !isChecked.value
}
</script>

<style lang="scss">
page {
	background-color: #121212 !important;
}
</style>

<style lang="scss" scoped>
.login-page {
	min-height: 100vh;
	background-color: #121212;
	padding: 24rpx 40rpx 60rpx;
	box-sizing: border-box;
}

.login-title {
	font-size: 56rpx;
	font-weight: bold;
	color: #FFFFFF;
	margin-bottom: 16rpx;
}

.login-subtitle {
	font-size: 26rpx;
	color: #9E9E9E;
	margin-bottom: 48rpx;
}

.form-card {
	background-color: #1E1E1E;
	border-radius: 16rpx;
	border: 1rpx solid rgba(212, 175, 55, 0.12);
	padding: 8rpx 24rpx 24rpx;
	margin-bottom: 40rpx;
}

.form-item {
	padding: 24rpx 0;
	border-bottom: 1rpx solid rgba(255, 255, 255, 0.06);

	&:last-child {
		border-bottom: none;
	}
}

.form-label {
	display: block;
	font-size: 24rpx;
	color: #9E9E9E;
	margin-bottom: 12rpx;
}

.form-input {
	width: 100%;
	font-size: 32rpx;
	color: #FFFFFF;
	background: transparent;
}

.input-placeholder {
	color: #666666;
}

.form-tip {
	font-size: 22rpx;
	color: #9E9E9E;
	padding: 8rpx 0 16rpx;
}

.captcha-row {
	display: flex;
	align-items: flex-end;
	gap: 20rpx;
	border-bottom: none;
	padding-bottom: 8rpx;
}

.captcha-input-wrap {
	flex: 1;
	min-width: 0;
}

.captcha-btn {
	flex-shrink: 0;
	height: 72rpx;
	line-height: 72rpx;
	padding: 0 24rpx;
	font-size: 26rpx;
	border-radius: 36rpx;
	background-color: #2A2A2A;
	color: #9E9E9E;
	border: 1rpx solid rgba(255, 255, 255, 0.1);
	margin-bottom: 4rpx;

	&::after {
		border: none;
	}

	&.active {
		background: linear-gradient(135deg, #E6C655, #D4AF37);
		color: #121212;
		font-weight: bold;
		border-color: transparent;
	}
}

.login-actions {
	display: flex;
	flex-direction: column;
	gap: 0;
}

.login-btn-primary {
	width: 100%;
	height: 90rpx;
	line-height: 90rpx;
	border-radius: 50rpx;
	background: linear-gradient(135deg, #E6C655, #D4AF37);
	color: #121212;
	font-size: 32rpx;
	font-weight: bold;
	border: none;
	box-shadow: 0 4rpx 16rpx rgba(212, 175, 55, 0.35);

	&::after {
		border: none;
	}

	&:active {
		opacity: 0.9;
		transform: scale(0.99);
	}
}

.divider {
	display: flex;
	align-items: center;
	margin: 28rpx 0 24rpx;
}

.login-footer {
	margin-top: 48rpx;
}

.divider-line {
	flex: 1;
	height: 1rpx;
	background-color: rgba(255, 255, 255, 0.08);
}

.divider-text {
	padding: 0 24rpx;
	font-size: 24rpx;
	color: #9E9E9E;
}

.login-btn-wechat {
	width: 100%;
	height: 88rpx;
	line-height: 88rpx;
	border-radius: 50rpx;
	background-color: #1E1E1E !important;
	color: #07C160 !important;
	font-size: 30rpx;
	font-weight: bold;
	border: 2rpx solid rgba(7, 193, 96, 0.5) !important;

	&::after {
		border: none;
	}
}

.agreement {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	width: 100%;
}

.agreement-radio {
	flex-shrink: 0;
	width: 40rpx;
	height: 36rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-right: 12rpx;
}

.agreement-text {
	flex: 1;
	font-size: 22rpx;
	color: #9E9E9E;
	line-height: 36rpx;
}

.link {
	color: #D4AF37;
}
</style>
