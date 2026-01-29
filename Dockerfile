# ========== 阶段一：构建 Vue 应用 ==========
FROM node:16-alpine AS builder

WORKDIR /app

# 可选：使用国内镜像加速
# RUN npm config set registry https://registry.npmmirror.com

# 复制依赖文件
COPY package.json pnpm-lock.yaml* package-lock.json* yarn.lock* ./

# 安装依赖（使用 npm，与 package.json 兼容）
RUN npm install

# 复制源码
COPY . .

# 生产环境构建
RUN npm run build:prod

# ========== 阶段二：使用 Nginx 提供静态资源 ==========
FROM nginx:alpine

# 复制自定义 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 从构建阶段复制打包产物到 nginx 默认静态目录
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
