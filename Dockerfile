# Self-host build for phanpy.wspanialy.eu (Paweł's fork).
# Coolify static buildpack can't inject build-time env into Vite, so we bake a
# .env.production.local (highest Vite precedence) inside the image build, then
# serve the static dist via nginx with SPA fallback.
FROM node:22-alpine AS build
WORKDIR /app
COPY . .
RUN printf 'PHANPY_DEFAULT_INSTANCE=wspanialy.eu\nPHANPY_CLIENT_NAME=Phanpy @ wspanialy.eu\nPHANPY_WEBSITE=https://phanpy.wspanialy.eu\n' > .env.production.local \
 && npm install \
 && npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
RUN printf 'server {\n  listen 80;\n  root /usr/share/nginx/html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 80
