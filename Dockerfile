FROM node:20-alpine AS development

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci && npm cache clean --force

###################
# BUILD FOR PRODUCTION
###################

FROM node:20-alpine AS build

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./
COPY --chown=node:node tsconfig.json ./

COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node src ./src

RUN npm run build

###################
# PRODUCTION
###################

FROM node:20-alpine AS production

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node --from=build /usr/src/app/dist ./dist

USER node

CMD [ "node", "dist/index.js" ]