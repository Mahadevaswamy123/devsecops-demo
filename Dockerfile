FROM node:20-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm ci && npm cache clean --force

COPY . .

RUN npm run build 

FROM nginx:alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

RUN rm -rf /usr/share/nginx/html/*

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html
RUN chown -R appuser:appgroup \ 
        /usr/share/nginx/html \
        /var/cache/nginx \
        /var/run \
        /var/log/nginx
USER appuser        

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
