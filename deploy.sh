#!/bin/sh
set -eu

cd "$(dirname "$0")"

set -a
. ./.env
set +a

: "${IMAGE_REGISTRY:?Не задан IMAGE_REGISTRY в .env}"
: "${VERSION:?Не задан VERSION в .env}"
: "${REGISTRY_USER:?Не задан REGISTRY_USER}"

HEALTH_URL="${HEALTH_URL:-http://localhost:${FRONTEND_PORT:-8888}/products}"
HEALTH_TRIES="${HEALTH_TRIES:-30}"
    
echo "==> Вход в registry ${IMAGE_REGISTRY}"
docker login "$IMAGE_REGISTRY" -u "$REGISTRY_USER" --password-stdin

echo "==> Загрузка образов версии ${VERSION}"
docker compose pull

echo "==> Запуск"
docker compose up -d --remove-orphans

echo "==> Очистка старых образов"
docker image prune -f

echo "$VERSION" > version

echo "==> Health-check: ${HEALTH_URL}"
i=0
until curl -fsS -o /dev/null "$HEALTH_URL"; do
  i=$((i + 1))
  if [ "$i" -ge "$HEALTH_TRIES" ]; then
    echo "ОШИБКА: приложение не ответило за $((HEALTH_TRIES * 2)) с" >&2
    docker compose ps
    docker compose logs --tail 50
    exit 1
  fi
  sleep 2
done

echo "==> OK: развёрнута версия ${VERSION}"
docker compose ps