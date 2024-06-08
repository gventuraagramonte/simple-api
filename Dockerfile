# Declaramos la base
FROM node:21-alpine3.19 AS base
# Instalar dependencias
FROM base as deps

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

# Construir la aplicación
FROM base as builder

WORKDIR /usr/src/app

COPY --from=deps /usr/src/app/node_modules ./node_modules

COPY . .

RUN npm run build

RUN npm ci -f --only=production && npm cache clean --force

# Imagen final
FROM base as prod

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY --from=builder /usr/src/app/dist ./dist

ENV NODE_ENV=production

USER node

EXPOSE 3000

CMD [ "node", "dist/main.js" ]