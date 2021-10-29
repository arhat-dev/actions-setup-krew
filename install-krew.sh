#!/usr/bin/env bash

set -eux

version="$1"

get_krew_os() {
  case "${RUNNER_OS}" in
  Linux)
    printf "linux"
    ;;
  Windows)
    printf "windows"
    ;;
  macOS)
    printf "darwin"
    ;;
  esac
}

get_krew_arch() {
  arch="amd64"
  if uname -m >&2; then
    arch=$(uname -m)
  fi

  case "${arch}" in
  amd64 | x86_64 | x64)
    printf "amd64"
    ;;
  arm64 | arm64v8 | armv8 | aarch64)
    printf "arm64"
    ;;
  *)
    # best effort, do something
    printf "amd64"
    ;;
  esac
}

krew_os="$(get_krew_os)"
krew_arch="$(get_krew_arch)"

cache_dir="${RUNNER_TOOL_CACHE:-"$(mktemp -d)"}/krew/${version}/${krew_arch}"

if [[ ! -d "${cache_dir}" ]]; then
  mkdir -p "${cache_dir}"

  echo "Installing krew..."
  curl -sSLo krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/download/${version}/krew-${krew_os}_${krew_arch}.tar.gz"
  tar -xzf krew.tar.gz -C "${cache_dir}"
  rm -f krew.tar.gz

  mv "${cache_dir}/krew-${krew_os}_${krew_arch}" "${cache_dir}/krew"
  chmod +x "${cache_dir}/krew"
  cp "${cache_dir}/krew" "${cache_dir}/kubectl-krew"
fi

"${cache_dir}/krew" version

echo "${cache_dir}" >>"${GITHUB_PATH}"
