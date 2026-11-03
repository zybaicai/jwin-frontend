import { fileURLToPath, URL } from 'node:url'
import type { IncomingMessage, ServerResponse } from 'node:http'

import vue from '@vitejs/plugin-vue'
import { defineConfig, type Plugin } from 'vite'

/**
 * 剥掉 FineReport 响应里的 X-Frame-Options / CSP frame-ancestors，
 * 允许 iframe 在跨域页面嵌入。
 */
function stripFrameProtection(): Plugin {
  return {
    name: 'strip-frame-protection',
    configureServer(server) {
      server.middlewares.use((req: IncomingMessage, res: ServerResponse, next) => {
        const url = req.url ?? ''
        if (!url.startsWith('/bi') && !url.startsWith('/webroot')) {
          next()
          return
        }
        // 拦截 setHeader / appendHeader，剥掉安全头
        const origSetHeader = res.setHeader.bind(res)
        res.setHeader = function (name: string, value: string | number | readonly string[]) {
          const low = name.toLowerCase()
          if (low === 'x-frame-options' || low === 'content-security-policy') {
            return res
          }
          return origSetHeader(name, value as never)
        } as ServerResponse['setHeader']
        next()
      })
    },
  }
}

// 代理目标来自后端实际配置：application.properties server.port=12002
export default defineConfig({
  plugins: [
    vue({
      template: {
        compilerOptions: {
          isCustomElement: (tag) => tag === 'iconify-icon',
        },
      },
    }),
    stripFrameProtection(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      // Vite 8 + 该包 exports 缺 default 时偶发解析失败，直指构建产物
      'element-china-area-data': fileURLToPath(
        new URL('./node_modules/element-china-area-data/dist/element-china-area-data.mjs', import.meta.url),
      ),
    },
  },
  optimizeDeps: {
    include: ['element-china-area-data'],
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:12002',
        changeOrigin: true,
      },
      // 悦发BI驾驶舱代理（绕过 FineReport X-Frame-Options: SAMEORIGIN）
      '/bi': {
        target: 'http://8.149.141.99:8080',
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/bi/, ''),
      },
      // FineReport 页面内部的资源大多用 /webroot/** 绝对路径，单独代理
      '/webroot': {
        target: 'http://8.149.141.99:8080',
        changeOrigin: true,
      },
    },
  },
})
