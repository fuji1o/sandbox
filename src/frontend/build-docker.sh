#!/bin/sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$PROJECT_ROOT/.env.nexus" ]; then
  set -a
  . "$PROJECT_ROOT/.env.nexus"
  set +a
fi

: "${NEXUS_REGISTRY:?Не задан NEXUS_REGISTRY}"
: "${NEXUS_USERNAME:?Не задан NEXUS_USERNAME}"
: "${NEXUS_PASSWORD:?Не задан NEXUS_PASSWORD}"
: "${NEXUS_FRONTEND_REPOSITORY:?Не задан NEXUS_FRONTEND_REPOSITORY}"

VERSION="${VERSION:-latest}"
IMAGE="${NEXUS_REGISTRY}/${NEXUS_FRONTEND_REPOSITORY}/sandbox-frontend"

echo "Вход в Nexus ${NEXUS_REGISTRY}..."
printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_REGISTRY" -u "$NEXUS_USERNAME" --password-stdin

echo "Сборка ${IMAGE}:${VERSION}..."
docker build --target runtime -t "${IMAGE}:${VERSION}" -t "${IMAGE}:latest" "$SCRIPT_DIR"

echo "Публикация в Nexus..."
docker push "${IMAGE}:${VERSION}"
if [ "$VERSION" != "latest" ]; then
  docker push "${IMAGE}:latest"
fi

echo "Готово: ${IMAGE}:${VERSION}"