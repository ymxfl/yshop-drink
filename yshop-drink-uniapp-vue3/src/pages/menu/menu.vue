<template>
	<layout>
		<uv-navbar
		  :fixed="false"
		  :title="title"
		  left-arrow
		  @leftClick="$onClickLeft"
		/>
		
		<view class="container" v-if="!loading">
			<!-- <view>
				<image :src="shopAd" mode="aspectFill" class="w-100 " style="height: 250rpx;"></image>
			</view> -->
			<view style="height: 60rpx;background-color: #FFFFFF;" v-if="store.notice">
					<uv-notice-bar  :text="store.notice"></uv-notice-bar>
			</view>
		<view class="main">
			<view class="nav">
				<view class="header">
					<view class="mr-1"><image :src="store.image" style="width:80rpx ; height: 80rpx; "></image></view>
					<view class="left" v-if="orderType == 'takein'" style="">
						<view class="store-name" @click="selectShop()">
							<text>{{ store.name }}</text>
							<view class="iconfont iconarrow-right"></view>
						</view>
						<view class="store-location">
							<text>距离您 {{kmUnit(store.dis)}}</text>
						</view>
					</view>
					<view class="left overflow-hidden" v-else>
						<view class="store-name" @click="selectShop()">
							<view>{{ store.name }}
								<text class="small" v-if="store.distance > 0 && orderType == 'takeout'">(配送距离:
									{{store.distance}}km)</text>
								<text class="small" v-else-if="orderType == 'takeout'">(本店不支持外卖)</text>
							</view>
							<view class="iconfont iconarrow-right"></view>
						</view>
					</view>
					<view class="right">
						<view class="dinein" :class="{active: orderType == 'takein'}" @tap="takein">
							<text>自取</text>
						</view>
						<view class="takeout" :class="{active: orderType == 'takeout'}" @tap="takout">
							<text>外卖</text>
						</view>
					</view>
				</view>
			</view>
		
			<!-- #ifdef H5 -->
			<view class="content"
				:style="{height: 'calc(100vh - 500rpx + '+(store.notice ? '0rpx':'60rpx')+')'}">
				<!-- #endif -->
				<!-- #ifndef H5 -->
				<view class="content" :style="{height: 'calc(100vh - 500rpx + '+(store.notice ? '0rpx':'60rpx')+')'}">
					<!-- #endif -->
					<scroll-view class="menus" :scroll-into-view="menuScrollIntoView" scroll-with-animation scroll-y>
						<view class="wrapper">
							<view class="menu" :id="`menu-${item.id}`" :class="{'current': item.id === currentCateId}"
								v-for="(item, index) in goods" :key="index" @tap="handleMenuTap(item.id)">
								<text>{{ item.name }}</text>
								<view class="dot" v-show="menuCartNum(item.id)">{{ menuCartNum(item.id) }}</view>
							</view>
						</view>
					</scroll-view>
					<!-- goods list begin -->
					<scroll-view class="goods" scroll-with-animation scroll-y :scroll-top="cateScrollTop"
						@scroll="handleGoodsScroll">
						<view class="wrapper">
							<view class="list">
								<!-- category begin -->
								<view class="category" v-for="(item, index) in goods" :key="index"
									:id="`cate-${item.id}`">
									<view class="title">
										<text>{{ item.name }}</text>
										<image mode="aspectFill" :src="item.icon" class="icon"></image>
									</view>
									<view class="items">
										<!-- 商品 begin -->
										<view class="good" v-for="(good, key) in item.goodsList" :key="key"
											:class="{'backgroud-grey': good.stock <= 0}">
											<image mode="aspectFill" :src="good.image" class="image"
												@tap="showGoodDetailModal(item, good)"></image>
											<view class="right">
												<text class="name">{{ good.storeName }}</text>
												<text class="tips">{{ good.storeInfo }}</text>
												<view class="price_and_action">
													<text class="price">￥{{ good.price }}</text>
													<view class="btn-group" v-if="good.stock > 0">
														<button type="primary" class="btn property_btn"
															hover-class="none" size="mini"
															@tap="showGoodDetailModal(item, good)">
															选规格
														</button>
														<view class="dot" v-show="goodCartNum(good.id)">
															{{ goodCartNum(good.id) }}</view>
													</view>
											

													<view v-if="good.stock == 0">已售罄</view>
												</view>

											</view>
										</view>
										<!-- 商品 end -->
									</view>
								</view>
								<!-- category end -->
								<view style="height: 110rpx;"></view>
							</view>
						</view>
					</scroll-view>
					<!-- goods list end -->
				</view>
				<!-- content end -->
				<!-- 购物车栏 begin -->
				<view class="cart-box" v-if="cart.length > 0 && isCartShow">
					<view class="mark">
						<image src="/static/images/menu/cart.png" class="cart-img" @tap="openCartPopup"></image>
						<view class="tag">{{ getCartGoodsNumber }}</view>
					</view>
					<view class="price" @tap="openCartShow">￥{{ getCartGoodsPrice }}</view>
					<button type="primary" class="pay-btn" @tap="toPay" :disabled="disabledPay">
						{{ disabledPay ? `差${spread}元起送` : '去结算' }}
					</button>
				</view>
				<!-- 购物车栏 end -->
			</view>
			<!-- 商品详情模态框 begin -->
			<modal :show="goodDetailModalVisible" class="good-detail-modal" color="#5A5B5C" width="90%" custom
				padding="0rpx" radius="12rpx">
				<view class="cover">
					<view class="btn-group">
						<image src="/static/images/menu/close.png" @tap="closeGoodDetailModal"></image>
					</view>
				</view>
				<scroll-view class="detail" scroll-y>
					<view v-if="good.image" class="image">
						<image :src="good.image"></image>
					</view>

					<view class="wrapper">
						<view class="basic">
							<view class="name">{{ good.storeName }}</view>
							<view class="tips flex justify-between">{{ good.storeInfo }} <text style="color: red;">可获积分:10</text></view>
						</view>
						<view class="properties">
							<view class="property" v-for="(item, index) in good.productAttr" :key="index">
								<view class="title">
									<text class="name">{{ item.attrName }}</text>
								</view>
								<view class="values">
									<view class="value" v-for="(value, key) in item.attrValueArr" :key="key"
										:class="{'default': value == newValue[index]}"
										@tap="changePropertyDefault(index, key,false)">
										{{ value }}
									</view>
								</view>
							</view>
						</view>
					</view>
				</scroll-view>
				<view class="action">
					<view class="left">
						<view class="price">￥{{ good.price }}</view>
						<view class="props">
							{{ good.valueStr }}
						</view>
					</view>
					<view class="btn-group">
						<text style="margin-right: 20rpx;">库存：{{good.stock}} </text>
						<button type="default" plain class="btn" size="mini" hover-class="none"
							@tap="handlePropertyReduce">
							<view class="iconfont iconsami-select"></view>
						</button>
						<view class="number">{{ good.number }}</view>
						<button type="primary" class="btn" size="min" hover-class="none" @tap="handlePropertyAdd">
							<view class="iconfont iconadd-select"></view>
						</button>
					</view>
				</view>
				<view class="add-to-cart-btn" @tap="handleAddToCartInModal">
					<view>加入购物车</view>
				</view>
			</modal>
			<!-- 商品详情模态框 end -->
			<!-- 购物车详情popup -->
			<uv-popup ref="popup" mode="bottom" class="cart-popup">
				<template #default>
				<view  class="cart-popup">
					 <view class="top">
					  <text @tap="handleCartClear">清空</text>
					 </view>
					 <scroll-view class="cart-list" scroll-y>
					  <view class="wrapper">
					   <view class="item" v-for="(item, index) in cart" :key="index">
						<view class="left">
						 <view class="name">{{ item.name }}</view>
						 <view class="props">{{ item.valueStr }}</view>
						</view>
						<view class="center">
						 <text>￥{{ item.price }}</text>
						</view>
						<view class="right">
						 <button type="default" plain size="mini" class="btn" hover-class="none"
						  @tap="handleCartItemReduce(index)">
						  <view class="iconfont iconsami-select"></view>
						 </button>
						 <view class="number">{{ item.number }}</view>
						 <button type="primary" class="btn" size="min" hover-class="none"
						  @tap="handleCartItemAdd(index)">
						  <view class="iconfont iconadd-select"></view>
						 </button>
						</view>
					   </view>
							
					  </view>
					 </scroll-view>
				 </view>
				</template>
			</uv-popup>
			   <!-- 购物车详情popup -->
			<uv-toast ref="uToast"></uv-toast>
		</view>
		<!--轻提示-->
		<view class="loading" v-else>
			<uv-loading-icon  color="#DA5650" size=40 mode="circle" ></uv-loading-icon>
			<button type="primary" style="z-index: 3001;position: absolute;top: 650rpx;" @click="init"
				v-if="!store.id">定位最近的门店</button>
		<!-- 	<uv-toast ref="uToast"></uv-toast> -->
		</view>
	</layout>
</template>

<script setup>
import {
  ref,
  computed,
  nextTick
} from 'vue'
import { useMainStore } from '@/store/store'
import { storeToRefs } from 'pinia'
import { onLoad,onShow ,onPullDownRefresh,onHide} from '@dcloudio/uni-app'
import { formatDateTime,kmUnit } from '@/utils/util'
import {
  shopNearby,
  menuGoods
} from '@/api/goods'
import {
  menuAds
} from '@/api/market'
const main = useMainStore()
const { orderType,address, store,location,isLogin } = storeToRefs(main)
const title = ref('点餐')
const text = ref('滚动通知')

const goods = ref([])
const ads = ref([])
const loading = ref(true) 
const currentCateId = ref(0)
const cateScrollTop = ref(0)
const menuScrollIntoView = ref('')
const cart = ref([])
const goodDetailModalVisible = ref(false)
const good= ref({})
const category = ref({})
const cartPopupVisible = ref(false)
const sizeCalcState = ref(false)
const newValue = ref([])
const shopAd = ref('')
const isCartShow = ref(true)
const popup = ref()



const newkmUnit = computed(() => (param) =>{
  console.log('param:',param)
  return '10km'
})
const goodCartNum = computed(() => { //计算单个饮品添加到购物车的数量
	return (id) => cart.value.reduce((acc, cur) => {
		if (cur.id === id) {
			return acc += cur.number
		}
		return acc
	}, 0)
})
const menuCartNum = computed(() =>{
	return (id) => cart.value.reduce((acc, cur) => {
		if (cur.cate_id === id) {
			return acc += cur.number
		}
		return acc
	}, 0)
})
const getCartGoodsNumber = computed(() => { //计算购物车总数
	return cart.value.reduce((acc, cur) => acc + cur.number, 0)
})
const getCartGoodsPrice = computed(() =>{ //计算购物车总价
	let price = cart.value.reduce((acc, cur) => acc + cur.number * cur.price, 0);
	return parseFloat(price).toFixed(2);
})
const disabledPay = computed(() => { //是否达到起送价
	return orderType.value == 'takeout' && (getCartGoodsPrice < parseFloat(store.value.min_price)) ? true :
		false
})
const spread = computed(() => { //差多少元起送
	if (orderType.value != 'takeout') return
	return parseFloat((store.value.min_price - getCartGoodsPrice).toFixed(2))
})

// 监听自定义事件
uni.$on('refreshMenu', () => {
	// 在这里执行onLoad逻辑
	console.log('refreshMenu1:',store.value.id)
	init()
})

onPullDownRefresh(() => {
	init()
})
onLoad(() => {
	init();
	refreshCart()
})
onHide(() => {
	// 重新进入要重新计算页面高度，否则有问题
	sizeCalcState.value = false;
})
onShow(() => {
	//init();
	refreshCart()
	shopAd.value = uni.getStorageSync('shopAd')
})

const openCartShow = () =>{
	isCartShow.value = false
}
const in_array = (search, array) => {
	for (var i in array) {
		if (array[i] == search) {
			return true;
		}
	}
	return false;
}
const selectShop = () => {
	uni.navigateTo({
		url: '/pages/components/pages/shop/shop'
	})
}
const uToast = ref()
const  init = async() => { //页面初始化
	loading.value = true;
    
	//return
	let error = {},
		result = location.value
	console.log('result:',result)
	if (!location.value.hasOwnProperty('latitude')) {
		  console.log('result1:',location.value)
		  uni.getLocation(({
			 type: 'wgs84',
			 success: function (res) {
			   console.log('location1:',res)
		
				result = {
					latitude: res.latitude,
					longitude: res.longitude
				};
				getShopList(result)
			 },
			 fail: function (res) {
			  
			   uni.showToast({
			     title: '获取位置失败，请检查是否开启相关权限',
			     duration: 2000,
			     icon: 'error'
			   });
			   // 默认地为你为北京地址
			   result = {
			   	latitude: 39.919990,
			   	longitude: 116.456270
			   };
			   getShopList(result)
			 },
			 complete: function (res) {
			 }
		}));
		 if(!result.hasOwnProperty('latitude')){
			result = {
				latitude: 39.919990,
				longitude: 116.456270
			};
			getShopList(result)
		 }
		return
	}
	
	getShopList(result)
   
	
}
const getShopList = async(res) => {
	 console.log('location9:',res)
	if (res) {
		main.SET_LOCATION(res);
	
		let shop_id = 0;
		if (store.value.id) {
			shop_id = store.value.id;
		}
	
		let shop = await shopNearby({
			lat: res.latitude,
			lng: res.longitude,
			shop_id: shop_id,
			kw: ''
		});
		if (shop) {
			//广告图
			getAds(shop.id);
	
			shop.notice = shop.status == 1 ? shop.notice : '店铺营业时间为:' + formatDateTime(shop.startTime,'hh:mm')+' - '+formatDateTime(shop.endTime,'hh:mm') +
			'，不在营业时间内无法下单';
			// 设置店铺信息
			main.SET_STORE(shop);
			let mygoods = await menuGoods({
				shopId: shop.id
			});
			if (mygoods) {
				goods.value = mygoods;
				refreshCart();
			}
			console.log('goods:',mygoods)
			console.log('goods:',goods.value)
			loading.value = false;
			uni.stopPullDownRefresh();
		}
	}
}
const refreshCart = () =>{
	if (goods.value && goods.value.length > 0) {
		let newGoods = goods.value;
		cart.value = [];
		let newCart = uni.getStorageSync('cart') || [];
		let tmpCart = [];
		if (newCart) {
			for (let i in newCart) {
				for (let ii in newGoods) {
					for (let iii in newGoods[ii].goodsList) {
						if (newCart[i].id == newGoods[ii].goodsList[iii].id) {
							tmpCart.push(newCart[i]);
						}
					}
				}
			}
			cart.value = tmpCart;
			cartPopupVisible.value = false;
		}
	}
}
const  getAds = async(shop_id) =>{
	let data = await menuAds({
		shop_id: shop_id ? shop_id : 0
	});
	if (data) {
		ads.value = data;
	}
}
const takout = (force = false) => {
	if (orderType.value == 'takeout' && force == false) return
	main.SET_ORDER_TYPE('takeout');

	if (!isLogin.value) {
		uni.navigateTo({
			url: '/pages/components/pages/login/login'
		})
		return
	} 

}
const takein = (force = false) => {
	if (orderType.value == 'takein' && force == false) return
	main.SET_ORDER_TYPE('takein');

	if (!isLogin.value) {
		uni.navigateTo({
			url: '/pages/components/pages/login/login'
		})
		return
	} 

}
const handleMenuTap = (id) => { //点击菜单项事件
	if (!sizeCalcState.value) {
		calcSize()
	}

	currentCateId.value = id
	nextTick(() => cateScrollTop.value = goods.value.find(item => item.id == id).top)
}
const handleGoodsScroll = ({ detail }) => { //商品列表滚动事件
	if (!sizeCalcState.value) {
		calcSize()
	}
	console.log('scrollTop:',detail)
	const {
		scrollTop
	} = detail
	let tabs = goods.value.filter(item => item.top <= scrollTop).reverse()
	if (tabs.length > 0) {
		currentCateId.value = tabs[0].id
	}
}
const calcSize = () => {
	let h = 10
	let view = uni.createSelectorQuery().select('#ads')
	if (view) {
		view.fields({
			size: true
		}, data => {
			if (data) {
				h += Math.floor(data.height)
			}
		}).exec()
	}
	goods.value.forEach(item => {
		let view = uni.createSelectorQuery().select(`#cate-${item.id}`)
		view.fields({
			size: true
		}, data => {
			console.log('h3:',h)
			item.top = h
			h += data.height
			item.bottom = h
		}).exec()
	})
	sizeCalcState.value = true
}
const handleAddToCart = (cate, newGood, num) =>{ //添加到购物车
	const index = cart.value.findIndex(item => {
		if (newGood) {
			return (item.id === newGood.id) && (item.valueStr === good.value.valueStr)
		} else {
			return item.id === newGood.id
		}
	})
	if (index > -1) {
		cart.value[index].number += num
	} else {
		cart.value.push({
			id: newGood.id,
			cate_id: cate.id,
			name: newGood.storeName,
			price: newGood.price,
			number: num,
			image: newGood.image,
			valueStr: good.value.valueStr
		})
	}
	uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const handleReduceFromCart = (item, good) => {
	const index = cart.value.findIndex(item => item.id === good.id)
	cart.value[index].number -= 1
	if (cart.value[index].number <= 0) {
		cart.value.splice(index, 1)
	}
	uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const showGoodDetailModal = (item, newGood) => {
	isCartShow.value = true
	good.value = JSON.parse(JSON.stringify({
		...newGood,
		number: 1
	}))
	
	if (!good.value.productAttr) {
		good.value.productAttr = [];
	}
	const hasTemp = good.value.productAttr.some(attr => attr.attrName === '饮用温度');
	if (!hasTemp) {
		good.value.productAttr.push({
			attrName: '饮用温度',
			attrValueArr: ['冰镇 4°C', '常温 15°C', '暖啤 35°C']
		});
	}
	
	category.value = JSON.parse(JSON.stringify(item))
	goodDetailModalVisible.value = true;
	console.log('goodDetailModalVisible:',goodDetailModalVisible.value)
	changePropertyDefault(0, 0,true);
}
const closeGoodDetailModal = () => { //关闭饮品详情模态框
	goodDetailModalVisible.value = false
    category.value = {}
	good.value = {}
}
const changePropertyDefault = (index, key, isDefault) => { //改变默认属性值
	let valueStr = ''
	console.log('good:',good.value)
	if(isDefault){
		newValue.value = []
		for(let i = 0;i < good.value.productAttr.length;i++){
			newValue.value[i] = good.value.productAttr[i].attrValueArr[0]
		}
	}else{
		newValue.value[index] = good.value.productAttr[index].attrValueArr[key]
	}
	
	valueStr = newValue.value.join(',')
	
	let skuValues = [];
	for (let i = 0; i < good.value.productAttr.length; i++) {
		if (good.value.productAttr[i].attrName !== '饮用温度') {
			skuValues.push(newValue.value[i]);
		}
	}
	let skuStr = skuValues.join(',');
	
	let productValue = good.value.productValue[skuStr]
	if(!productValue) {
		let skukey = JSON.parse(JSON.stringify(skuValues))
		skukey.sort((a, b) => a.localeCompare(b))
		skuStr = skukey.join(',')
		productValue = good.value.productValue[skuStr]
	}
	
	if (productValue) {
		good.value.price = parseFloat(productValue.price).toFixed(2);
		good.value.stock = productValue.stock;
		good.value.image = productValue.image ? productValue.image : good.value.image;
	}
	good.value.number = 1;
	good.value.valueStr = valueStr
}
const handlePropertyAdd = () => {
	good.value.number += 1
}
const handlePropertyReduce = () => {
	if (good.value.number === 1) return
	good.value.number -= 1
}
const handleAddToCartInModal = () => {
	if (good.value.stock <= 0) {
		uToast.value.show({message:'商品库存不足',type: 'error'});
		return;
	}
	handleAddToCart(category.value, good.value, good.value.number)
	closeGoodDetailModal()
}
const openCartPopup = () => { //打开/关闭购物车列表popup
	popup.value.open()
}
const handleCartClear = () => { //清空购物车
	uni.showModal({
		title: '提示',
		content: '确定清空购物车么',
		success: ({
			confirm
		}) => {
			if (confirm) {
				popup.value.close()
				cart.value = []
				uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
			}
		}
	})
}
const handleCartItemAdd = (index) => {
	cart.value[index].number += 1
	uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const handleCartItemReduce = (index) => {
	if (cart.value[index].number === 1) {
		cart.value.splice(index, 1)
	} else {
		cart.value[index].number -= 1
	}
	if (!cart.value.length) {
		cartPopupVisible.value = false
	}
	uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))
}
const toPay = () => {

	if (!isLogin.value) {
		uni.navigateTo({
			url: '/pages/components/pages/login/login'
		})
		return
	} else {
		if (store.value.status == 0) {
			uToast.value.show({message:'不在店铺营业时间内',type: 'error'});
			return;
		}
		if(orderType.value == 'takeout' && store.value.distance <= 0){
			uToast.value.show({message:'本店不支持外卖',type: 'error'});
			return;
		}
		// 判断当前是否在配送范围内
		if (orderType.value == 'takeout' && store.value.distance < store.value.far) {
			uToast.value.show({message:'选中的地址不在配送范围',type: 'error'});
			return;
		}

		uni.showLoading({
			title: '加载中'
		})
		uni.setStorageSync('cart', JSON.parse(JSON.stringify(cart.value)))

		uni.navigateTo({
			url: '/pages/components/pages/pay/pay'
		})
	}

	uni.hideLoading()
}

</script>

<style lang="scss" scoped>

	/* #ifdef H5 */
	page {
		height: auto;
		min-height: 100%;
	}
	/* #endif */
	
	.container {
		overflow: hidden;
		position: relative;
		background-color: #121212;
	}
	
	.loading {
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #121212;
	
		image {
			width: 260rpx;
			height: 260rpx;
			position: relative;
			margin-top: -200rpx;
			/* #ifdef h5 */
			margin-top: 0;
			/* #endif */
		}
	}
	
	
	.main {
		width: 100%;
		height: 100%;
		position: relative;
		background-color: #121212;
	}
	
	.nav {
		width: 100%;
		height: 140rpx;
		display: flex;
		flex-direction: column;
	
		.header {
			width: 100%;
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 20rpx 30rpx;
			background-color: #1E1E1E;
			border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
			height: 140rpx;
			color: #FFFFFF;
	
			.left {
				flex: 1;
				display: flex;
				flex-direction: column;
	
				.store-name {
					display: flex;
					justify-content: flex-start;
					align-items: center;
					font-size: 32rpx;
					font-weight: bold;
					margin-bottom: 8rpx;
					color: #FFFFFF;
					.small {
						font-size: $font-size-sm;
						color: #9E9E9E;
					}
					.iconfont {
						margin-left: 10rpx;
						line-height: 100%;
						color: #D4AF37;
					}
				}
	
				.store-location {
					display: flex;
					justify-content: flex-start;
					align-items: center;
					color: #9E9E9E;
					font-size: $font-size-sm;
	
					.iconfont {
						vertical-align: middle;
						display: table-cell;
						color: $color-primary;
						line-height: 100%;
					}
				}
			}
	
			.right {
				background-color: #2A2A2A;
				border-radius: 38rpx;
				display: flex;
				align-items: center;
				font-size: $font-size-sm;
				padding: 0 38rpx;
				color: #9E9E9E;
				height: 64rpx;
	
				.dinein,
				.takeout {
					position: relative;
					display: flex;
					align-items: center;
					color: #9E9E9E;
					font-weight: bold;
					&.active {
						padding: 10rpx 30rpx;
						color: #121212;
						background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
						border-radius: 38rpx;
					}
				}
	
				.takeout {
					margin-left: 20rpx;
					height: 100%;
					flex: 1;
					padding: 14rpx 0;
				}
	
				.dinein.active {
					margin-left: -38rpx;
				}
	
				.takeout.active {
					margin-right: -38rpx;
				}
			}
		}
	}
	
	.content {
		width: 100%;
		height: calc(100vh - 212rpx);
		/* #ifdef H5 */
		height: calc(100vh - 212rpx - 188rpx);
		/* #endif */
		display: flex;
		background-color: #121212;
	
		.menus {
			width: 200rpx;
			height: 100%;
			overflow: hidden;
			background-color: #121212;
	
			.wrapper {
				width: 100%;
				height: 100%;
	
				.menu {
					display: flex;
					align-items: center;
					justify-content: flex-start;
					padding: 35rpx 20rpx;
					font-size: 26rpx;
					color: #9E9E9E;
					position: relative;
					background-color: #121212;
					transition: all 0.2s ease;
	
					&.current {
						background-color: #1E1E1E;
						color: #D4AF37;
						font-weight: bold;
						
						&::before {
							content: '';
							position: absolute;
							left: 0;
							top: 25%;
							height: 50%;
							width: 6rpx;
							background-color: #D4AF37;
							border-radius: 0 4rpx 4rpx 0;
						}
					}
	
					.dot {
						position: absolute;
						width: 32rpx;
						height: 32rpx;
						line-height: 32rpx;
						font-size: 20rpx;
						background-color: #D4AF37;
						color: #121212;
						font-weight: bold;
						top: 16rpx;
						right: 10rpx;
						border-radius: 100%;
						text-align: center;
					}
				}
				.menu:last-child {
					margin-bottom: 200rpx;
				}
			}
		}
	
		.goods {
			flex: 1;
			height: 100%;
			overflow: hidden;
			background-color: #1E1E1E;
	
			.wrapper {
				width: 100%;
				height: 100%;
				padding: 20rpx;
				background-color: #1E1E1E;
	
				.ads {
					height: calc(300 / 550 * 510rpx);
					margin-bottom: 20rpx;
	
					image {
						width: 100%;
						height: 100%;
						border-radius: 16rpx;
					}
				}
	
				.list {
					width: 100%;
					font-size: $font-size-base;
	
					.category {
						width: 100%;
	
						.title {
							padding: 30rpx 0;
							display: flex;
							align-items: center;
							color: #FFFFFF;
							font-weight: bold;
							font-size: 30rpx;
	
							.icon {
								width: 38rpx;
								height: 38rpx;
								margin-left: 10rpx;
							}
						}
					}
					.category:last-child {
						margin-bottom: 200rpx;
					}
	
					.items {
						display: flex;
						flex-direction: column;
	
						.good {
							display: flex;
							align-items: center;
							padding: 20rpx;
							background-color: rgba(255, 255, 255, 0.02);
							border: 1rpx solid rgba(255, 255, 255, 0.05);
							border-radius: 16rpx;
							margin-bottom: 20rpx;
							transition: all 0.2s ease;
							
							&:active {
								background-color: rgba(255, 255, 255, 0.05);
							}
							
							.image {
								width: 160rpx;
								height: 160rpx;
								margin-right: 20rpx;
								border-radius: 16rpx;
							}
	
							.right {
								flex: 1;
								height: 160rpx;
								overflow: hidden;
								display: flex;
								flex-direction: column;
								align-items: flex-start;
								justify-content: space-between;
								padding-right: 10rpx;
	
								.name {
									font-size: 28rpx;
									font-weight: bold;
									color: #FFFFFF;
									margin-bottom: 8rpx;
									width: 100%;
									overflow: hidden;
									text-overflow: ellipsis;
									white-space: nowrap;
								}
	
								.tips {
									width: 100%;
									height: 40rpx;
									line-height: 40rpx;
									overflow: hidden;
									text-overflow: ellipsis;
									white-space: nowrap;
									font-size: 22rpx;
									color: #9E9E9E;
									margin-bottom: 8rpx;
								}
	
								.price_and_action {
									width: 100%;
									display: flex;
									justify-content: space-between;
									align-items: center;
	
									.price {
										font-size: 32rpx;
										font-weight: bold;
										color: #D4AF37;
									}
	
									.btn-group {
										display: flex;
										justify-content: space-between;
										align-items: center;
										position: relative;
	
										.btn {
											padding: 0 24rpx;
											box-sizing: border-box;
											font-size: 22rpx;
											height: 46rpx;
											line-height: 46rpx;
											font-weight: bold;
	
											&.property_btn {
												border-radius: 24rpx;
												background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
												color: #121212;
												border: none;
											}
										}
	
										.dot {
											position: absolute;
											background-color: #D4AF37;
											color: #121212;
											font-weight: bold;
											font-size: 20rpx;
											width: 32rpx;
											height: 32rpx;
											line-height: 32rpx;
											text-align: center;
											border-radius: 100%;
											right: -12rpx;
											top: -10rpx;
										}
	
										.number {
											width: 44rpx;
											height: 44rpx;
											line-height: 44rpx;
											text-align: center;
											color: #FFFFFF;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	
	.good-detail-modal {
		background-color: #1E1E1E;
		color: #FFFFFF;
	
		.cover {
			height: 20rpx;
			display: flex;
			justify-content: center;
			align-items: center;
	
			.btn-group {
				position: absolute;
				right: 15rpx;
				top: 15rpx;
				display: flex;
				align-items: center;
				justify-content: space-around;
				z-index: 210;
				 
				image {
					width: 50rpx;
					height: 50rpx;
					opacity: 0.7;
				}
			}
		}
	
		.detail {
			width: 100%;
			min-height: 1vh;
			max-height: calc(90vh - 320rpx - 80rpx - 120rpx);
			position: relative;
			background-color: #1E1E1E;
	
			.image {
				display: flex;
				justify-content: center;
				align-items: center;
				padding: 30rpx 0;
				background-color: #121212;
				image {
					width: 260rpx;
					height: 260rpx;
				}
			}
			.wrapper {
				width: 100%;
				height: 100%;
				overflow: hidden;
				padding-top: 20rpx;
	
				.basic {
					padding: 20rpx 30rpx;
					display: flex;
					flex-direction: column;
					.name {
						font-size: 32rpx;
						font-weight: bold;
						color: #FFFFFF;
						margin-bottom: 8rpx;
					}
					.tips {
						font-size: 24rpx;
						color: #9E9E9E;
					}
				}
	
				.properties {
					width: 100%;
					border-top: 1rpx solid rgba(255, 255, 255, 0.05);
					padding: 20rpx 30rpx 0;
					display: flex;
					flex-direction: column;
	
					.property {
						width: 100%;
						display: flex;
						flex-direction: column;
						margin-bottom: 30rpx;
	
						.title {
							width: 100%;
							display: flex;
							justify-content: flex-start;
							align-items: center;
							margin-bottom: 16rpx;
	
							.name {
								font-size: 26rpx;
								color: #FFFFFF;
								font-weight: bold;
								margin-right: 20rpx;
							}
	
							.desc {
								flex: 1;
								font-size: 22rpx;
								color: #D4AF37;
								overflow: hidden;
								text-overflow: ellipsis;
								white-space: nowrap;
							}
						}
	
						.values {
							width: 100%;
							display: flex;
							flex-wrap: wrap;
	
							.value {
								border-radius: 8rpx;
								background-color: #2A2A2A;
								padding: 12rpx 28rpx;
								font-size: 24rpx;
								color: #9E9E9E;
								margin-right: 16rpx;
								margin-bottom: 16rpx;
								border: 1rpx solid transparent;
								transition: all 0.2s ease;
	
								&.default {
									background-color: rgba(212, 175, 55, 0.1);
									color: #D4AF37;
									border: 1rpx solid #D4AF37;
									font-weight: bold;
								}
							}
						}
					}
				}
			}
		}
	
		.action {
			display: flex;
			align-items: center;
			justify-content: space-between;
			background-color: #121212;
			height: 120rpx;
			padding: 0 30rpx;
			border-top: 1rpx solid rgba(255, 255, 255, 0.05);
	
			.left {
				flex: 1;
				display: flex;
				flex-direction: column;
				justify-content: center;
				margin-right: 20rpx;
				overflow: hidden;
	
				.price {
					font-size: 36rpx;
					font-weight: bold;
					color: #D4AF37;
				}
	
				.props {
					color: #9E9E9E;
					font-size: 22rpx;
					width: 100%;
					overflow: hidden;
					text-overflow: ellipsis;
					white-space: nowrap;
				}
			}
			.btn-group {
				display: flex;
				align-items: center;
				justify-content: space-around;
				color: #FFFFFF;
	
				.number {
					font-size: $font-size-base;
					width: 44rpx;
					height: 44rpx;
					line-height: 44rpx;
					text-align: center;
				}
	
				.btn {
					padding: 0;
					font-size: $font-size-base;
					width: 44rpx;
					height: 44rpx;
					line-height: 44rpx;
					border-radius: 100%;
					background-color: #D4AF37;
					color: #121212;
					border: none;
					display: flex;
					align-items: center;
					justify-content: center;
				}
			}
		}
	
		.add-to-cart-btn {
			display: flex;
			justify-content: center;
			align-items: center;
			background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%);
			color: #121212;
			font-weight: bold;
			font-size: 30rpx;
			height: 88rpx;
			border-radius: 0 0 16rpx 16rpx;
		}
	}
	
	.cart-box {
		position: fixed;
		bottom: 30rpx;
		/* #ifdef H5 */
		bottom: calc(var(--window-bottom) + 20rpx);
		/* #endif */
		left: 30rpx;
		right: 30rpx;
		height: 96rpx;
		border-radius: 48rpx;
		box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.4);
		background-color: rgba(30, 30, 30, 0.95);
		border: 1rpx solid rgba(212, 175, 55, 0.4);
		display: flex;
		align-items: center;
		justify-content: space-between;
		z-index: 9999;
		backdrop-filter: blur(10px);
	
		.cart-img {
			width: 96rpx;
			height: 96rpx;
			position: relative;
			margin-top: -30rpx;
			transition: transform 0.2s ease;
			&:active {
				transform: scale(0.9);
			}
		}
	
		.pay-btn {
			height: 100%;
			padding: 0 40rpx;
			background: linear-gradient(135deg, #E6C655 0%, #D4AF37 100%) !important;
			color: #121212 !important;
			border-radius: 0 48rpx 48rpx 0;
			display: flex;
			align-items: center;
			font-size: 30rpx;
			font-weight: bold;
			border: none;
		}
	
		.mark {
			padding-left: 46rpx;
			margin-right: 30rpx;
			position: relative;
	
			.tag {
				background-color: #D4AF37;
				color: #121212;
				font-weight: bold;
				display: flex;
				justify-content: center;
				align-items: center;
				font-size: 20rpx;
				position: absolute;
				right: -10rpx;
				top: -50rpx;
				border-radius: 100%;
				padding: 4rpx;
				width: 36rpx;
				height: 36rpx;
				border: 2rpx solid #121212;
			}
		}
	
		.price {
			flex: 1;
			color: #D4AF37;
			font-size: 36rpx;
			font-weight: bold;
			padding-left: 20rpx;
		}
	}
	
	.cart-popup {
		background-color: #1E1E1E;
		border-radius: 24rpx 24rpx 0 0;
		color: #FFFFFF;
		
		.top {
			background-color: #121212;
			color: #9E9E9E;
			padding: 16rpx 30rpx;
			font-size: 24rpx;
			text-align: right;
			border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
		}
		.cart-list {
			background-color: #1E1E1E;
			width: 100%;
			overflow: hidden;
			min-height: 1vh;
			max-height: 60vh;
	
			.wrapper {
				height: 100%;
				display: flex;
				flex-direction: column;
				padding: 0 30rpx;
				margin-bottom: 156rpx;
	
				.item {
					display: flex;
					justify-content: space-between;
					align-items: center;
					padding: 30rpx 0;
					position: relative;
					border-bottom: 1rpx solid rgba(255, 255, 255, 0.05);
	
					.left {
						flex: 1;
						display: flex;
						flex-direction: column;
						overflow: hidden;
						margin-right: 30rpx;
	
						.name {
							font-size: 28rpx;
							font-weight: bold;
							color: #FFFFFF;
						}
						.props {
							color: #9E9E9E;
							font-size: 22rpx;
							overflow: hidden;
							text-overflow: ellipsis;
							white-space: nowrap;
							margin-top: 4rpx;
						}
					}
	
					.center {
						margin-right: 120rpx;
						font-size: 28rpx;
						color: #D4AF37;
						font-weight: bold;
					}
	
					.right {
						display: flex;
						align-items: center;
						justify-content: space-between;
	
						.btn {
							width: 46rpx;
							height: 46rpx;
							border-radius: 100%;
							padding: 0;
							text-align: center;
							line-height: 46rpx;
							background-color: #D4AF37;
							color: #121212;
							border: none;
							display: flex;
							align-items: center;
							justify-content: center;
						}
	
						.number {
							font-size: 28rpx;
							width: 46rpx;
							height: 46rpx;
							text-align: center;
							line-height: 46rpx;
							color: #FFFFFF;
						}
					}
				}
			}
		}
	}
	
	.backgroud-grey {
		background-color: rgba(255, 255, 255, 0.05);
		opacity: 0.5;
		padding: 15rpx !important;
	}
</style>
