#!/usr/bin/env bash
# deploy-web.sh — runs ON THE VPS. Downloads a saimo-app Flutter web (wasm) release,
# extracts it into a versioned folder, and atomically points /srv/saimo-web/current
# at it. Caddy serves /srv/saimo-web/current (see saimo-web.caddy), so no Caddy
# restart is needed. Idempotent: re-running the same version just re-extracts it.
#
#   Usage:  sudo ./deploy-web.sh              # deploys v1.0.11
#           sudo ./deploy-web.sh v1.0.12      # deploys another tag
#           sudo GITHUB_TOKEN=ghp_xxx ./deploy-web.sh   # if the repo is private
#
# Rollback: sudo ln -sfn /srv/saimo-web/releases/<old-tag> /srv/saimo-web/current
set -euo pipefail

REPO="Amirh-dev/saimo-app"
TAG="${1:-v1.0.11}"
ASSET="saimo-web-wasm.tar.gz"
WEB_ROOT="${WEB_ROOT:-/srv/saimo-web}"
KEEP_RELEASES="${KEEP_RELEASES:-5}"

RELEASE_DIR="${WEB_ROOT}/releases/${TAG}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${WEB_ROOT}/releases"

echo "Downloading ${ASSET} (${TAG})..."
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  # Private repo: resolve the asset id through the API, then download it.
  ASSET_ID="$(curl -fsSL \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO}/releases/tags/${TAG}" \
    | grep -B3 "\"name\": \"${ASSET}\"" | grep -m1 '"id":' | tr -dc '0-9')"
  [[ -n "${ASSET_ID}" ]] || { echo "Asset ${ASSET} not found in release ${TAG}" >&2; exit 1; }
  curl -fSL --retry 3 \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/octet-stream" \
    -o "${TMP_DIR}/${ASSET}" \
    "https://api.github.com/repos/${REPO}/releases/assets/${ASSET_ID}"
else
  curl -fSL --retry 3 -o "${TMP_DIR}/${ASSET}" \
    "https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"
fi

echo "Extracting..."
mkdir -p "${TMP_DIR}/extract"
tar -xzf "${TMP_DIR}/${ASSET}" -C "${TMP_DIR}/extract"

# The tarball may hold files at its root or under a folder (e.g. build/web/).
# Use whichever directory contains index.html, shallowest first.
INDEX="$(find "${TMP_DIR}/extract" -name index.html -printf '%d %p\n' | sort -n | head -1 | cut -d' ' -f2-)"
[[ -n "${INDEX}" ]] || { echo "No index.html found in ${ASSET}" >&2; exit 1; }
SRC_DIR="$(dirname "${INDEX}")"

rm -rf "${RELEASE_DIR}"
mkdir -p "${RELEASE_DIR}"
cp -a "${SRC_DIR}/." "${RELEASE_DIR}/"

# Caddy runs as the 'caddy' user; make the files readable.
chmod -R a+rX "${RELEASE_DIR}"

echo "Switching ${WEB_ROOT}/current -> ${TAG}..."
ln -sfn "${RELEASE_DIR}" "${WEB_ROOT}/current.tmp"
mv -Tf "${WEB_ROOT}/current.tmp" "${WEB_ROOT}/current"

echo "Pruning old releases (keeping ${KEEP_RELEASES})..."
ls -1dt "${WEB_ROOT}"/releases/*/ | tail -n +"$((KEEP_RELEASES + 1))" | xargs -r rm -rf

echo "Deployed ${TAG} to ${WEB_ROOT}/current"
