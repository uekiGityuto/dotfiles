# コマンド

そこそこ使うけど覚えられないコマンド

## Docker

- ログイン:
  ```
  docker exec -it [コンテナ名] bash
  ```
- 使用されていない image を削除(タグなし、他コンテナからも参照なし):
  ```
  docker image prune
  ```
- 停止コンテナを削除:
  ```
  docker container prune
  ```
- 未使用の Volume を削除:
  ```
  docker volume prune
  ```
- 未使用なコンテナ, イメージ, ネットワーク、Volume を一括削除:
  ```
  docker system prune --volumes
  ```

## Linux

- 全ディレクトから検索:
  ```
  sudo find / -name test.txt
  ```
- ポートを利用しているプロセス確認
  ```
  lsof -i:8082
  ```
- プロセス確認:
  ```
  ps aux
  ```
  `aux`をつけることで網羅的に情報が取れる
- curl: 例

  ```
  curl -XGET -H "Content-Type: application/json" http://127.0.0.1:8000/member/

  curl -XPOST -H "Content-Type: application/json" -d '{"name" : "ueki", "sex" : "0", "email" : "ueki@example.com"}' http://127.0.0.1:8000/member/
  ```

## K8s

### 切り替え

- context 切り替え:
  ```
  kubectx [context名]
  ```
- namespace 切り替え:
  ```
  kubens [namespace名]
  ```

### 調査

- kube-proxy:
  ```
  kubectl port-forward <target_pod's_name> 8080:8082
  ```
- 調査用の Pod 作成:
  ```
  kubectl run ueki-pod --image=nginx --restart=Never --rm -it -- sh
  ```
  ```
  kubectl run ueki-pod --image=mysql:5.7 --restart=Never --rm -it -- sh`
  ```

## Git

### 軽い気持ちで実施できること

- リモートリポジトリ追加

  ```
  git remote add origin git@github.com:uekiGityuto/sql-expt.git
  ```

- 差分ファイル確認

  ```
  git diff --name-only feature/3032-ModifyEnum
  ```

- リモートブランチとの差分確認

  ```
  git fetch origin feature/3032-PreferredUsernameType
  git diff --name-status feature/3032-PreferredUsernameType origin/feature/3032-PreferredUsernameType
  ```

- ブランチ間での差分確認

  ```
  git diff feature/docker-batch feature/3956-add-ddtrace-batch
  ```

- 直前のコミットメッセージ修正

  ```
  git commit --amend -m "an updated commit message"
  ```

- 退避
  ```
  git stash -u
  ```
- 直前の退避を戻す

  ```
  git stash apply
  ```

- ブランチ名変更
  ```
  git branch -m feature/3032-ModifyAccountType
  ```

### 注意して実施すべきこと

- リモートブランチ削除

  ```
  git push --delete origin 3032-ModifyAccountType
  ```

- ローカルブランチ削除（マージ済みであれば削除）

  ```
  git branch -d feature/3032-AccountAuthenticationType
  ```

  `feature/cryptotrend/`を含むローカルブランチ一括削除

  ```
  git branch | grep feature/cryptotrend/ | xargs git branch -d
  ```

- ローカルブランチ削除（マージしていないブランチでも削除）

  ```
  git branch -D feature/3032-AccountAuthenticationType
  ```

- （head もローカルも）全て指定のコミットに戻す

  ```
  git reset --hard 2fe83545c0ff2ac6eabe8abd6d80de55ab78103b
  ```

- （head もローカルも）全て直前のコミットに戻す

  ```
  git reset --hard HEAD^
  ```

- head だけ直前のコミットに戻す（ワークディレクトリはそのまま）

  ```
  git reset --soft HEAD^
  ```

- 強制 push
  ```
  git push --force-with-lease origin feature/3032-ModifyEnum
  ```

## MySQL

- ログイン
  ```
  mysql -u refbatmember -p -D member
  ```
- スキーマ確認

  ```
  SHOW DATABASES;
  SHOW TABLES;
  DESC [table名]
  SHOW CLOUMNS FROM [table名]
  ```

## PostgreSQL

- ログイン

  ```
  psql -U postgres -d fuelkinri
  ```

- メタコマンド
  ```
  # メタコマンド一覧
  \?
  # DB一覧
  \l
  # テーブル、ビュー、シーケンスの一覧
  \d
  # テーブル一覧
  \dt
  # カラム一覧
  \d [talble名]
  ```
