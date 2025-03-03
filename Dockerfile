# https://stackoverflow.com/questions/53681522/share-variable-in-multi-stage-dockerfile-arg-before-from-not-substituted
ARG PROJECT_DIR=/vue3-antdv-admin

# 使用阿里云镜像源
FROM node:18 as builder
ARG PROJECT_DIR
WORKDIR $PROJECT_DIR

# 安装pnpm
RUN npm install -g pnpm

COPY . ./
# 安装依赖
# 使用淘宝源来加速依赖安装
RUN pnpm config set registry https://registry.npmmirror.com
RUN pnpm install

# 构建项目
ENV VITE_BASE_URL=/
RUN pnpm build


# 使用阿里云镜像源
FROM nginx:alpine as production
ARG PROJECT_DIR

COPY --from=builder $PROJECT_DIR/dist/ /usr/share/nginx/html
COPY --from=builder $PROJECT_DIR/nginx.conf /etc/nginx/nginx.conf

EXPOSE 6666
