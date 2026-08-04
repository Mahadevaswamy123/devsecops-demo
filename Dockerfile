FROM node:20-alpine as build

WORKDIR /app

COPY package*.json ./

RUN groupadd -r appuser && useradd -r -g appuser appuser

RUN npm ci && npm cache clean --force

USER appuser

COPY . .

RUN npm run build 

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
