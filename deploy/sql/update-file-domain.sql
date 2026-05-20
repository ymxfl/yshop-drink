-- 将演示环境 localhost/127.0.0.1 文件域名替换为生产 HTTPS 主站
-- 执行：在 DB 机或通过 3336 端口连接 yixiang-drink-open
-- 目标域名：https://wine.joshuatech.cn

SET NAMES utf8mb4;

-- 1) 文件存储主配置（新上传走此 domain）
UPDATE infra_file_config
SET config = REPLACE(REPLACE(REPLACE(REPLACE(config,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE deleted = 0;

-- 2) 已上传文件记录 URL
UPDATE infra_file
SET url = REPLACE(REPLACE(REPLACE(REPLACE(url,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE url LIKE '%localhost%' OR url LIKE '%127.0.0.1%';

-- 3) 业务表：轮播、素材、优惠券、服务入口、分类、商品、积分商品、会员头像等
UPDATE yshop_shop_ads
SET image = REPLACE(REPLACE(REPLACE(REPLACE(image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%';

UPDATE yshop_material
SET url = REPLACE(REPLACE(REPLACE(REPLACE(url,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE url LIKE '%localhost%' OR url LIKE '%127.0.0.1%';

UPDATE yshop_coupon
SET image = REPLACE(REPLACE(REPLACE(REPLACE(image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%';

UPDATE yshop_service
SET image = REPLACE(REPLACE(REPLACE(REPLACE(image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%';

UPDATE yshop_store_product_category
SET pic_url = REPLACE(REPLACE(REPLACE(REPLACE(pic_url,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE pic_url LIKE '%localhost%' OR pic_url LIKE '%127.0.0.1%' OR pic_url LIKE '%apidc.yixiang.co%';

UPDATE yshop_store_product_category
SET pic_url = REPLACE(pic_url, 'https://apidc.yixiang.co', 'https://wine.joshuatech.cn')
WHERE pic_url LIKE '%apidc.yixiang.co%';

UPDATE yshop_store_product
SET image = REPLACE(REPLACE(REPLACE(REPLACE(image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn'),
    slider_image = REPLACE(REPLACE(REPLACE(REPLACE(slider_image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn'),
    description = REPLACE(REPLACE(REPLACE(REPLACE(description,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%'
   OR slider_image LIKE '%localhost%' OR slider_image LIKE '%127.0.0.1%'
   OR description LIKE '%localhost%' OR description LIKE '%127.0.0.1%';

UPDATE yshop_score_product
SET image = REPLACE(REPLACE(REPLACE(REPLACE(image,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn'),
    images = REPLACE(REPLACE(REPLACE(REPLACE(images,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn'),
    `desc` = REPLACE(REPLACE(REPLACE(REPLACE(`desc`,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%'
   OR images LIKE '%localhost%' OR images LIKE '%127.0.0.1%'
   OR `desc` LIKE '%localhost%' OR `desc` LIKE '%127.0.0.1%';

UPDATE yshop_user
SET avatar = REPLACE(REPLACE(REPLACE(REPLACE(avatar,
    ' http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://localhost:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48081', 'https://wine.joshuatech.cn'),
    'http://127.0.0.1:48080', 'https://wine.joshuatech.cn')
WHERE avatar LIKE '%localhost%' OR avatar LIKE '%127.0.0.1%';

-- 4) 旧演示 CDN（若存在）
UPDATE infra_file_config
SET config = REPLACE(REPLACE(config,
    'https://h5.yixiang.co', 'https://wine.joshuatech.cn'),
    'https://apidc.yixiang.co', 'https://wine.joshuatech.cn')
WHERE config LIKE '%yixiang.co%';

UPDATE yshop_score_product
SET image = REPLACE(image, 'https://apidc.yixiang.co', 'https://wine.joshuatech.cn'),
    images = REPLACE(images, 'https://apidc.yixiang.co', 'https://wine.joshuatech.cn'),
    `desc` = REPLACE(`desc`, 'https://apidc.yixiang.co', 'https://wine.joshuatech.cn')
WHERE image LIKE '%apidc.yixiang.co%' OR images LIKE '%apidc.yixiang.co%' OR `desc` LIKE '%apidc.yixiang.co%';

-- 5) 修正 JSON domain 前导空格（演示数据常见 " http://..."）
UPDATE infra_file_config
SET config = REPLACE(config, '" https://wine.joshuatech.cn"', '"https://wine.joshuatech.cn"')
WHERE config LIKE '%" https://wine.joshuatech.cn"%';

-- 校验：应无 localhost 残留（业务表）
SELECT 'yshop_shop_ads' AS tbl, COUNT(*) AS cnt FROM yshop_shop_ads WHERE image LIKE '%localhost%' OR image LIKE '%127.0.0.1%'
UNION ALL
SELECT 'infra_file_config', COUNT(*) FROM infra_file_config WHERE config LIKE '%localhost%' OR config LIKE '%127.0.0.1%'
UNION ALL
SELECT 'yshop_material', COUNT(*) FROM yshop_material WHERE url LIKE '%localhost%' OR url LIKE '%127.0.0.1%';
