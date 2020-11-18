# NeWork Notify

## Notification of NeWork's rooms status to Slack

NeWorkの状況を可視化して雑談をよりしやすくするためのツール

## Parameters

`TOKEN_API_KEY` と `REFRESH_TOKEN` はGoogle ChromeのDevToolなどを利用して取得してください。

- NEWORK_WORKSPACE: NeWorkのワークスペース名（例: `nttcom` ）
- TOKEN_API_KEY: `https://securetoken.googleapis.com/v1/token?key=...` の `key=...` の部分
- REFRESH_TOKEN: `https://securetoken.googleapis.com/v1/token?key=...` のレスポンスボディ参照
- SLACK_API_TOKEN: SlackにPostするようのToken（Slackで取得）
- SLACK_CHANNEL: Postしたいチャンネル名（例: `#remote` ）

## Usage

```
$ export NEWORK_WORKSPACE=nttcom
$ export TOKEN_API_KEY=...
$ export REFRESH_TOKEN=...
$ export SLACK_CHANNEL="#remote"
$ export SLACK_API_TOKEN=...
$ bundle exec ruby lib/nework-notify.rb
```
