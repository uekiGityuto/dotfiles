# コマンド

Mac でよく使うコマンドメモ

## Docker

- ログイン:
  `docker exec -it [コンテナ名] bash`
- 使用されていない image を削除(タグなし、他コンテナからも参照なし):
  `docker image prune`
- 停止コンテナを削除
  docker container prune
- 未使用の Volume を削除:
  `docker volume prune`
- 未使用なコンテナ, イメージ, ネットワーク、Volume を一括削除:
  `docker system prune --volumes`

## Linux

- 全ディレクトから検索:
  `sudo find / -name test.txt`
- ポートを利用しているプロセス確認:
  `lsof -i:8082`
- プロセス確認:
  `ps aux`
  - `aux`をつけることで網羅的に情報が取れる

## K8s

### 切り替え

- context 切り替え
  `kubectx [context名]`
- namespace 切り替え
  `kubens [namespace名]`

### 調査

- kube-proxy
  `kubectl port-forward <target_pod's_name> 8080:8082`
- 調査用 Pod
  - `kubectl run ueki-pod --image=nginx --restart=Never --rm -it -- sh`
  - `kubectl run ueki-pod --image=mysql:5.7 --restart=Never --rm -it -- sh`
