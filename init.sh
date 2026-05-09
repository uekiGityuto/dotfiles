#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

## インストール処理
./install.sh

## Homebrewパッケージのインストール
make brew-install

## Miseで言語/ツールをインストール
make mise-install

## uv toolのインストール
make uv-install
