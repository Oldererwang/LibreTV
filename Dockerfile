FROM node:lts-alpine

LABEL maintainer="LibreTV Team"
LABEL description="LibreTV - 免费在线视频搜索与观看平台"

# 设置环境变量
ENV PORT=8080
ENV CORS_ORIGIN=*
ENV DEBUG=false
ENV REQUEST_TIMEOUT=5000
ENV MAX_RETRIES=2
ENV CACHE_MAX_AGE=1d

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json（如果存在）
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production && npm cache clean --force

# 复制应用文件
COPY . .

# 环境变量注入（假设用 nginx 或 http-server）
ENV PROXY_URL=https://api.codetabs.com/v1/proxy?quest=
# 构建后用脚本注入到 index.html 或 window.__ENV__
# 例如:
# RUN sed -i "s|window.__ENV__.PROXY_URL = .*|window.__ENV__.PROXY_URL = \"$PROXY_URL\";|" /usr/share/nginx/html/index.html

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# 启动应用
CMD ["npm", "start"]
