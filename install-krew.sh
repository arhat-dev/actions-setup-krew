#!/usr/bin/env bash

set -eux

version="$1"

krew_os=""
arch="amd64"
if uname -m; then
  arch=$(uname -m)
else
  krew_os="windows"
fi

cache_dir="${RUNNER_TOOL_CACHE:-"$(mktemp -d)"}/krew/${version}/${arch}"

krew_arch="amd64"
case "${arch}" in
  amd64 | x86_64 | x64)
    krew_arch="amd64"
    ;;
  arm64 | arm64v8 | armv8 | aarch64)
    krew_arch="arm64"
    ;;
esac

if [[ -z "${krew_os}" ]]; then
  if command -v podman >/dev/null 2>&1; then
  krew_os="linux"
  elif command -v xcode-select >/dev/null 2>&1; then
    krew_os="darwin"
  elif command -v choco >/dev/null 2>&1; then
    krew_os="windows"
  else
    echo "Cannot determine os type" >&2
    exit 1
  fi
fi

if [[ ! -d "${cache_dir}" ]]; then
  mkdir -p "${cache_dir}"

  echo "Installing krew..."
  curl -sSLo krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/download/${version}/krew-${krew_os}_${krew_arch}.tar.gz"
  tar -xzf krew.tar.gz -C "${cache_dir}"
  rm -f krew.tar.gz

  mv "${cache_dir}/krew-${krew_os}_${krew_arch}" "${cache_dir}/krew"
  chmod +x "${cache_dir}/krew"
fi

"${cache_dir}/krew" version

echo "${cache_dir}" >>"${GITHUB_PATH}"
