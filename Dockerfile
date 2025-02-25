# 1. Node.js 빌드 단계
FROM node:22-alpine as build
WORKDIR /app

# package.json과 lock 파일만 복사하여 의존성 설치 최적화
COPY package*.json package-lock.json ./
RUN npm ci --omit=dev

# 애플리케이션 소스 코드 복사 및 빌드 실행
COPY . .
RUN NODE_OPTIONS="--max-old-space-size=4096" npm run build

# 2. Nginx로 서빙하는 단계
FROM nginx:stable-alpine
USER root

# 빌드된 파일을 Nginx의 정적 파일 디렉터리에 복사
COPY --from=build /app/build /usr/share/nginx/html

# Nginx 설정 파일 복사 (불필요한 삭제 명령 제거)
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# (선택 사항) 엔트리포인트 스크립트가 있다면 복사 및 실행 권한 부여
# COPY docker-entrypoint.sh /docker-entrypoint.sh
# RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
