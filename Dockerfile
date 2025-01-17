ARG NODE_VERSION='20.11.1'

FROM node:${PG_VERSION}-alpine AS build

ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

WORKDIR /app

COPY package*.json tsconfig.json ./
COPY src ./src

RUN npm ci && \
    npm run build && \
    npm prune --production

FROM node:${PG_VERSION}-alpine

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./

ARG PG_VERSION='16'

RUN apk add --update --no-cache postgresql${PG_VERSION}-client

CMD pg_isready --dbname=$BACKUP_DATABASE_URL && \
    pg_dump --version && \
    node dist/index.js
