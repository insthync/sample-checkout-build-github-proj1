# BUILD
FROM node:18-alpine as builder

WORKDIR /usr/src/app

# Bundle app source
ADD . .

# Install app dependencies
RUN npm install -f

# Creates a "dist" folder with the production build
RUN npm run build

# RUN
FROM node:18-alpine

COPY --from=0 /usr/src/app/package*.json /app/
COPY --from=0 /usr/src/app/dist/ /app/dist/
COPY --from=0 /usr/src/app/tsconfig.json /app/tsconfig.json

WORKDIR /app

# Install required libs
RUN apk upgrade --update-cache --available && \
    apk add openssl && \
    rm -rf /var/cache/apk/*

# Install PM2 globally
RUN npm install -g pm2

# Install packages
RUN npm install -f

# Listening on PORT 80
ENV PORT=80
EXPOSE 80

# Use pm2-runtime to start main.js in Docker
CMD ["pm2-runtime", "./dist/main.js"]
