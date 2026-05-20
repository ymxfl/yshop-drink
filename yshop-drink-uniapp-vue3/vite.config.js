import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import uni from '@dcloudio/vite-plugin-uni';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// H5 必须使用 @dcloudio/uni-h5-vue 提供的 Vue 运行时（含 injectHook 等 uni 扩展导出）
const uniH5VueRuntime = path.resolve(
  __dirname,
  'node_modules/@dcloudio/uni-h5-vue/dist/vue.runtime.esm.js'
);

export default defineConfig({
  plugins: [uni()],
  resolve: {
    alias: {
      vue: uniH5VueRuntime,
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        // 抑制 Dart Sass 弃用提示（主要来自 uni_modules/uv-ui 与 Vite 旧版 sass.render API）
        silenceDeprecations: ['legacy-js-api', 'import', 'global-builtin'],
        quietDeps: true,
      },
    },
  },
});
