#!/bin/bash

# git設定
git config --global user.name "Yuto Ueki"
git config --global user.email "ueki.yuto.bz@gmail.com"
git config --global core.editor 'vim -c "set fenc=utf-8"'
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global push.default simple

## インストール処理
./install.sh
