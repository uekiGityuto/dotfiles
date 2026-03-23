#!/bin/bash

## インストール処理
./install.sh

## Homebrewパッケージのインストール
make brew-install

## Miseで言語/ツールをインストール
make mise-install

## uv toolのインストール
make uv-install
