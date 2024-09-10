# check-instance

## 概要

aws コマンドでインスタンスのリストを取得し、想定外のインスタンスが起動していたら slack に通知する。

ここに置いてあるスクリプトは、一回、上記の動作を行うのみ。定期的に実行するには、cron で`main.bash`を実行する。

## cron の設定

1. `crontab -e`でエディタが起動する
1. `0 8 * * * <レポジトリのパス>/main.bash`を追記する（毎朝 8 時にチェックする）

## incoming webhook の設定

incoming webhook 用の URL が必要。[ドキュメント](https://api.slack.com/messaging/webhooks#getting-started)を読んで用意する。

`credentials/urls.json`に、以下の内容で登録しておく。

```json
{
  "url": "取得したURL"
}
```

## aws コマンドのプロファイル

aws コマンド実行時に、`hotoku`というプロファイルを利用する。
それによって得られた結果に対してチェックをする。

認証方法についての詳細は省略。設定の実態は`~/.aws/config`, `~/.aws/credentials`ファイルである。
