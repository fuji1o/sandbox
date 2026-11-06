FROM node:16-alpine AS builder

WORKDIR /src

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:16-alpine AS runtime

RUN npm install -g http-server

WORKDIR /app
COPY --from=builder /src/dist /app/site

ENV BACKEND_URL=http://backend:8081

USER node
EXPOSE 8888
CMD ["sh", "-c", "http-server /app/site -p 8888 --proxy ${BACKEND_URL}"]